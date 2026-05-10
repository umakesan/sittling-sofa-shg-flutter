from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, Numeric, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from app.db.session import Base


class SofaLoanEntry(Base):
    __tablename__ = "sofa_loan_entries"
    __table_args__ = (UniqueConstraint("month_entry_id", "loan_slot", name="uq_entry_slot"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    month_entry_id: Mapped[int] = mapped_column(ForeignKey("month_entries.id"), nullable=False)
    loan_slot: Mapped[int] = mapped_column(Integer, nullable=False)
    disbursed: Mapped[float] = mapped_column(Numeric(12, 2), default=0, nullable=False)
    repayment: Mapped[float] = mapped_column(Numeric(12, 2), default=0, nullable=False)
    interest_collected: Mapped[float] = mapped_column(Numeric(12, 2), default=0, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.utcnow, onupdate=datetime.utcnow
    )
