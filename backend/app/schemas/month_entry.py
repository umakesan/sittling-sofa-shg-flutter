from datetime import date, datetime

from pydantic import BaseModel, Field

from app.models.month_entry import EntryMode, EntryStatus


class MonthEntryBase(BaseModel):
    group_id: int
    entry_month: date
    entry_mode: EntryMode
    savings_collected: float = Field(default=0, ge=0)
    internal_loan_principal_disbursed: float = Field(default=0, ge=0)
    internal_loan_interest_collected: float = Field(default=0, ge=0)
    to_bank: float = Field(default=0, ge=0)
    from_bank: float = Field(default=0, ge=0)
    sofa_loan_disbursed: float = Field(default=0, ge=0)
    sofa_loan_repayment: float = Field(default=0, ge=0)
    sofa_loan_interest_collected: float = Field(default=0, ge=0)
    notes: str | None = None


class MonthEntryCreate(MonthEntryBase):
    pass


class MonthEntryUpdate(BaseModel):
    savings_collected: float | None = Field(default=None, ge=0)
    internal_loan_principal_disbursed: float | None = Field(default=None, ge=0)
    internal_loan_interest_collected: float | None = Field(default=None, ge=0)
    to_bank: float | None = Field(default=None, ge=0)
    from_bank: float | None = Field(default=None, ge=0)
    sofa_loan_disbursed: float | None = Field(default=None, ge=0)
    sofa_loan_repayment: float | None = Field(default=None, ge=0)
    sofa_loan_interest_collected: float | None = Field(default=None, ge=0)
    notes: str | None = None
    status: EntryStatus | None = None


class MonthEntryRead(MonthEntryBase):
    id: int
    status: EntryStatus
    warning_flags: list[str]
    source_count: int
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
