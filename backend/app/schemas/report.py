from pydantic import BaseModel


class DashboardSummary(BaseModel):
    total_savings_collected: float
    total_internal_loan_principal: float
    total_internal_loan_interest: float
    total_sofa_disbursed: float
    total_sofa_repaid: float
    warning_entry_count: int


class LedgerMonthValue(BaseModel):
    month: str
    value: float


class GroupLedgerRow(BaseModel):
    metric: str
    values: list[LedgerMonthValue]
