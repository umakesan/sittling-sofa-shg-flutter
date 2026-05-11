from fastapi import APIRouter

from app.api.v1.endpoints import auth, groups, month_entries, reports, sofa_loans, villages


api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(groups.router, prefix="/groups", tags=["groups"])
api_router.include_router(villages.router, prefix="/villages", tags=["villages"])
api_router.include_router(month_entries.router, prefix="/month-entries", tags=["month-entries"])
api_router.include_router(reports.router, prefix="/reports", tags=["reports"])
api_router.include_router(sofa_loans.router, tags=["sofa-loans"])
