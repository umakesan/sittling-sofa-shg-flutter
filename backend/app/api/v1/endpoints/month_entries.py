from datetime import date

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.api.deps import db_session
from app.models.month_entry import MonthEntry
from app.models.sofa_loan import SofaLoan
from app.models.sofa_loan_entry import SofaLoanEntry
from app.schemas.month_entry import MonthEntryCreate, MonthEntryRead, MonthEntryUpdate
from app.services.validation import build_warning_flags, derive_status

router = APIRouter()


def _to_read(entry: MonthEntry, sle: SofaLoanEntry | None) -> MonthEntryRead:
    return MonthEntryRead(
        id=entry.id,
        group_id=entry.group_id,
        entry_month=entry.entry_month,
        entry_mode=entry.entry_mode,
        status=entry.status,
        savings_collected=float(entry.savings_collected),
        internal_loan_principal_disbursed=float(entry.internal_loan_principal_disbursed),
        internal_loan_interest_collected=float(entry.internal_loan_interest_collected),
        to_bank=float(entry.to_bank),
        from_bank=float(entry.from_bank),
        notes=entry.notes,
        warning_flags=entry.warning_flags or [],
        source_count=entry.source_count,
        sofa_loan_entry_id=entry.sofa_loan_entry_id,
        sofa_disbursed=float(sle.disbursed) if sle else 0.0,
        sofa_repayment=float(sle.repayment) if sle else 0.0,
        sofa_interest=float(sle.interest_collected) if sle else 0.0,
        created_at=entry.created_at,
        updated_at=entry.updated_at,
    )


def _upsert_sofa(
    db: Session,
    group_id: int,
    entry_month: date,
    disbursed: float,
    repayment: float,
    interest: float,
) -> SofaLoanEntry:
    active_loan = (
        db.query(SofaLoan)
        .filter(SofaLoan.group_id == group_id, SofaLoan.status == "active")
        .first()
    )
    if not active_loan:
        raise HTTPException(
            status_code=422,
            detail="No active SOFA loan for this group. Create one first.",
        )

    sle = (
        db.query(SofaLoanEntry)
        .filter(
            SofaLoanEntry.sofa_loan_id == active_loan.id,
            SofaLoanEntry.entry_month == entry_month,
        )
        .first()
    )
    if sle:
        sle.disbursed = disbursed
        sle.repayment = repayment
        sle.interest_collected = interest
    else:
        sle = SofaLoanEntry(
            sofa_loan_id=active_loan.id,
            entry_month=entry_month,
            disbursed=disbursed,
            repayment=repayment,
            interest_collected=interest,
        )
        db.add(sle)
        db.flush()

    return sle


@router.get("", response_model=list[MonthEntryRead])
def list_month_entries(db: Session = Depends(db_session)) -> list[MonthEntryRead]:
    pairs = (
        db.query(MonthEntry, SofaLoanEntry)
        .outerjoin(SofaLoanEntry, MonthEntry.sofa_loan_entry_id == SofaLoanEntry.id)
        .order_by(MonthEntry.entry_month.desc())
        .all()
    )
    return [_to_read(entry, sle) for entry, sle in pairs]


@router.post("", response_model=MonthEntryRead)
def create_month_entry(
    payload: MonthEntryCreate, db: Session = Depends(db_session)
) -> MonthEntryRead:
    sofa_disbursed = payload.sofa_disbursed
    sofa_repayment = payload.sofa_repayment
    sofa_interest = payload.sofa_interest

    entry_data = payload.model_dump(
        exclude={"sofa_disbursed", "sofa_repayment", "sofa_interest"}
    )
    entry = MonthEntry(**entry_data)

    sle = None
    if sofa_disbursed or sofa_repayment or sofa_interest:
        sle = _upsert_sofa(
            db, payload.group_id, payload.entry_month,
            sofa_disbursed, sofa_repayment, sofa_interest,
        )
        entry.sofa_loan_entry_id = sle.id

    entry.warning_flags = build_warning_flags(entry)
    entry.status = derive_status(entry.warning_flags)
    db.add(entry)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="An entry for this group and month already exists.",
        )
    db.refresh(entry)
    if sle:
        db.refresh(sle)
    return _to_read(entry, sle)


@router.get("/{entry_id}", response_model=MonthEntryRead)
def get_month_entry(entry_id: int, db: Session = Depends(db_session)) -> MonthEntryRead:
    entry = db.get(MonthEntry, entry_id)
    if entry is None:
        raise HTTPException(status_code=404, detail="Month entry not found")
    sle = db.get(SofaLoanEntry, entry.sofa_loan_entry_id) if entry.sofa_loan_entry_id else None
    return _to_read(entry, sle)


@router.patch("/{entry_id}", response_model=MonthEntryRead)
def update_month_entry(
    entry_id: int,
    payload: MonthEntryUpdate,
    db: Session = Depends(db_session),
) -> MonthEntryRead:
    entry = db.get(MonthEntry, entry_id)
    if entry is None:
        raise HTTPException(status_code=404, detail="Month entry not found")

    fields = payload.model_dump(exclude_unset=True)
    sofa_disbursed = fields.pop("sofa_disbursed", None)
    sofa_repayment = fields.pop("sofa_repayment", None)
    sofa_interest = fields.pop("sofa_interest", None)

    for key, value in fields.items():
        setattr(entry, key, value)

    sle = None
    if any(v is not None for v in (sofa_disbursed, sofa_repayment, sofa_interest)):
        current_sle = (
            db.get(SofaLoanEntry, entry.sofa_loan_entry_id)
            if entry.sofa_loan_entry_id else None
        )
        new_disbursed = sofa_disbursed if sofa_disbursed is not None else (float(current_sle.disbursed) if current_sle else 0.0)
        new_repayment = sofa_repayment if sofa_repayment is not None else (float(current_sle.repayment) if current_sle else 0.0)
        new_interest = sofa_interest if sofa_interest is not None else (float(current_sle.interest_collected) if current_sle else 0.0)

        if new_disbursed or new_repayment or new_interest:
            sle = _upsert_sofa(
                db, entry.group_id, entry.entry_month,
                new_disbursed, new_repayment, new_interest,
            )
            entry.sofa_loan_entry_id = sle.id

    if sle is None and entry.sofa_loan_entry_id:
        sle = db.get(SofaLoanEntry, entry.sofa_loan_entry_id)

    entry.warning_flags = build_warning_flags(entry)
    entry.status = derive_status(entry.warning_flags)
    db.add(entry)
    db.commit()
    db.refresh(entry)
    return _to_read(entry, sle)
