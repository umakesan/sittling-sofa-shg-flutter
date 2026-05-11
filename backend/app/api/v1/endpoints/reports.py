from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.api.deps import db_session
from app.models.month_entry import MonthEntry
from app.models.sofa_loan_entry import SofaLoanEntry
from app.schemas.report import DashboardSummary

router = APIRouter()


@router.get("/dashboard", response_model=DashboardSummary)
def get_dashboard(db: Session = Depends(db_session)) -> DashboardSummary:
    totals = (
        db.query(
            func.coalesce(func.sum(MonthEntry.savings_collected), 0),
            func.coalesce(func.sum(MonthEntry.internal_loan_principal_disbursed), 0),
            func.coalesce(func.sum(MonthEntry.internal_loan_interest_collected), 0),
            func.coalesce(func.sum(SofaLoanEntry.disbursed), 0),
            func.coalesce(func.sum(SofaLoanEntry.repayment), 0),
        )
        .select_from(MonthEntry)
        .outerjoin(SofaLoanEntry, MonthEntry.sofa_loan_entry_id == SofaLoanEntry.id)
        .one()
    )
    warning_count = sum(
        1 for (warning_flags,) in db.query(MonthEntry.warning_flags).all() if warning_flags
    )

    return DashboardSummary(
        total_savings_collected=float(totals[0]),
        total_internal_loan_principal=float(totals[1]),
        total_internal_loan_interest=float(totals[2]),
        total_sofa_disbursed=float(totals[3]),
        total_sofa_repaid=float(totals[4]),
        warning_entry_count=int(warning_count),
    )
