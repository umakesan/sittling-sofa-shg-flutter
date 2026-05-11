from datetime import date

from fastapi import APIRouter, Depends, HTTPException, status as http_status
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.api.deps import db_session
from app.models.group import Group
from app.models.sofa_loan import SofaLoan
from app.models.sofa_loan_entry import SofaLoanEntry
from app.schemas.sofa_loan import SofaLoanCreate, SofaLoanRead
from app.schemas.sofa_loan_entry import SofaLoanEntryRead

router = APIRouter()


def _outstanding(loan: SofaLoan, db: Session) -> float:
    total_repaid = db.query(
        func.coalesce(func.sum(SofaLoanEntry.repayment), 0)
    ).filter(SofaLoanEntry.sofa_loan_id == loan.id).scalar()
    return float(loan.principal_amount) - float(total_repaid)


def _to_loan_read(loan: SofaLoan, db: Session) -> SofaLoanRead:
    return SofaLoanRead(
        id=loan.id,
        group_id=loan.group_id,
        name=loan.name,
        principal_amount=float(loan.principal_amount),
        disbursed_date=loan.disbursed_date,
        status=loan.status,
        closed_date=loan.closed_date,
        outstanding=_outstanding(loan, db),
        created_at=loan.created_at,
        updated_at=loan.updated_at,
    )


@router.get("/groups/{group_id}/sofa-loans", response_model=list[SofaLoanRead])
def list_sofa_loans(group_id: int, db: Session = Depends(db_session)) -> list[SofaLoanRead]:
    loans = (
        db.query(SofaLoan)
        .filter(SofaLoan.group_id == group_id)
        .order_by(SofaLoan.status.asc(), SofaLoan.disbursed_date.desc())
        .all()
    )
    return [_to_loan_read(loan, db) for loan in loans]


@router.post(
    "/groups/{group_id}/sofa-loans",
    response_model=SofaLoanRead,
    status_code=http_status.HTTP_201_CREATED,
)
def create_sofa_loan(
    group_id: int,
    payload: SofaLoanCreate,
    db: Session = Depends(db_session),
) -> SofaLoanRead:
    group = db.get(Group, group_id)
    if not group:
        raise HTTPException(status_code=404, detail="Group not found.")

    existing_active = (
        db.query(SofaLoan)
        .filter(SofaLoan.group_id == group_id, SofaLoan.status == "active")
        .first()
    )
    if existing_active:
        raise HTTPException(
            status_code=409,
            detail="An active SOFA loan already exists for this group.",
        )

    count = db.query(SofaLoan).filter(SofaLoan.group_id == group_id).count()
    loan = SofaLoan(
        group_id=group_id,
        name=f"{group.code}-sofaloan-{count + 1}",
        principal_amount=payload.principal_amount,
        disbursed_date=payload.disbursed_date,
        status="active",
    )
    db.add(loan)
    db.commit()
    db.refresh(loan)
    return _to_loan_read(loan, db)


@router.post("/sofa-loans/{loan_id}/close", response_model=SofaLoanRead)
def close_sofa_loan(loan_id: int, db: Session = Depends(db_session)) -> SofaLoanRead:
    loan = db.get(SofaLoan, loan_id)
    if not loan:
        raise HTTPException(status_code=404, detail="SOFA loan not found.")
    if loan.status == "closed":
        raise HTTPException(status_code=422, detail="Loan is already closed.")

    outstanding = _outstanding(loan, db)
    if outstanding > 0:
        raise HTTPException(
            status_code=422,
            detail=f"Outstanding balance ₹{outstanding:.0f} must be zero before closing.",
        )

    loan.status = "closed"
    loan.closed_date = date.today()
    db.commit()
    db.refresh(loan)
    return _to_loan_read(loan, db)


@router.get("/sofa-loans/{loan_id}/entries", response_model=list[SofaLoanEntryRead])
def list_sofa_loan_entries(
    loan_id: int, db: Session = Depends(db_session)
) -> list[SofaLoanEntry]:
    loan = db.get(SofaLoan, loan_id)
    if not loan:
        raise HTTPException(status_code=404, detail="SOFA loan not found.")
    return (
        db.query(SofaLoanEntry)
        .filter(SofaLoanEntry.sofa_loan_id == loan_id)
        .order_by(SofaLoanEntry.entry_month.asc())
        .all()
    )
