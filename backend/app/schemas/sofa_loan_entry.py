from datetime import date, datetime

from pydantic import BaseModel


class SofaLoanEntryRead(BaseModel):
    id: int
    sofa_loan_id: int
    entry_month: date
    disbursed: float = 0.0
    repayment: float = 0.0
    interest_collected: float = 0.0
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
