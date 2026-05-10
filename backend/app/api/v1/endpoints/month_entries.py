from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.api.deps import db_session
from app.models.month_entry import MonthEntry
from app.schemas.month_entry import MonthEntryCreate, MonthEntryRead, MonthEntryUpdate
from app.services.validation import build_warning_flags, derive_status


router = APIRouter()


@router.get("", response_model=list[MonthEntryRead])
def list_month_entries(db: Session = Depends(db_session)) -> list[MonthEntry]:
    return db.query(MonthEntry).order_by(MonthEntry.entry_month.desc()).all()


@router.post("", response_model=MonthEntryRead)
def create_month_entry(payload: MonthEntryCreate, db: Session = Depends(db_session)) -> MonthEntry:
    entry = MonthEntry(**payload.model_dump())
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
    return entry


@router.get("/{entry_id}", response_model=MonthEntryRead)
def get_month_entry(entry_id: int, db: Session = Depends(db_session)) -> MonthEntry:
    entry = db.get(MonthEntry, entry_id)
    if entry is None:
        raise HTTPException(status_code=404, detail="Month entry not found")
    return entry


@router.patch("/{entry_id}", response_model=MonthEntryRead)
def update_month_entry(
    entry_id: int,
    payload: MonthEntryUpdate,
    db: Session = Depends(db_session),
) -> MonthEntry:
    entry = db.get(MonthEntry, entry_id)
    if entry is None:
        raise HTTPException(status_code=404, detail="Month entry not found")

    for key, value in payload.model_dump(exclude_unset=True).items():
        setattr(entry, key, value)

    entry.warning_flags = build_warning_flags(entry)
    entry.status = derive_status(entry.warning_flags)
    db.add(entry)
    db.commit()
    db.refresh(entry)
    return entry
