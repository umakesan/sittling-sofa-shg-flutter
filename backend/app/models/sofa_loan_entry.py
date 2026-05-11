from datetime import date, datetime

from sqlalchemy import Date, DateTime, ForeignKey, Numeric, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.session import Base


class SofaLoanEntry(Base):
    __tablename__ = "sofa_loan_entries"
    __table_args__ = (UniqueConstraint("sofa_loan_id", "entry_month", name="uq_loan_month"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    sofa_loan_id: Mapped[int] = mapped_column(ForeignKey("sofa_loans.id"), nullable=False)
    entry_month: Mapped[date] = mapped_column(Date, nullable=False)
    disbursed: Mapped[float] = mapped_column(Numeric(12, 2), default=0, nullable=False)
    repayment: Mapped[float] = mapped_column(Numeric(12, 2), default=0, nullable=False)
    interest_collected: Mapped[float] = mapped_column(Numeric(12, 2), default=0, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.utcnow, onupdate=datetime.utcnow
    )

    loan: Mapped["SofaLoan"] = relationship("SofaLoan", back_populates="entries")  # noqa: F821
