from datetime import date, datetime

from pydantic import BaseModel, Field


class SofaLoanCreate(BaseModel):
    principal_amount: float = Field(..., gt=0)
    disbursed_date: date


class SofaLoanRead(BaseModel):
    id: int
    group_id: int
    name: str
    principal_amount: float
    disbursed_date: date
    status: str
    closed_date: date | None = None
    outstanding: float = 0.0
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
