from datetime import date, datetime
from enum import Enum

from sqlalchemy import Date, DateTime, Enum as SqlEnum, ForeignKey, JSON, Numeric, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from app.db.session import Base


class EntryMode(str, Enum):
    MANUAL = "manual"
    PREFILL = "prefill"


class EntryStatus(str, Enum):
    DRAFT = "draft"
    SAVED = "saved"
    SAVED_WITH_WARNINGS = "saved_with_warnings"
    SYNCED = "synced"


class MonthEntry(Base):
    __tablename__ = "month_entries"
    __table_args__ = (UniqueConstraint("group_id", "entry_month", name="uq_group_month"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    group_id: Mapped[int] = mapped_column(ForeignKey("groups.id"), nullable=False)
    entry_month: Mapped[date] = mapped_column(Date, nullable=False)
    entry_mode: Mapped[EntryMode] = mapped_column(SqlEnum(EntryMode), nullable=False)
    status: Mapped[EntryStatus] = mapped_column(
        SqlEnum(EntryStatus), default=EntryStatus.DRAFT, nullable=False
    )
    savings_collected: Mapped[float] = mapped_column(Numeric(12, 2), default=0, nullable=False)
    internal_loan_principal_disbursed: Mapped[float] = mapped_column(
        Numeric(12, 2), default=0, nullable=False
    )
    internal_loan_interest_collected: Mapped[float] = mapped_column(
        Numeric(12, 2), default=0, nullable=False
    )
    to_bank: Mapped[float] = mapped_column(Numeric(12, 2), default=0, nullable=False)
    from_bank: Mapped[float] = mapped_column(Numeric(12, 2), default=0, nullable=False)
    sofa_loan_disbursed: Mapped[float] = mapped_column(Numeric(12, 2), default=0, nullable=False)
    sofa_loan_repayment: Mapped[float] = mapped_column(Numeric(12, 2), default=0, nullable=False)
    sofa_loan_interest_collected: Mapped[float] = mapped_column(
        Numeric(12, 2), default=0, nullable=False
    )
    notes: Mapped[str | None] = mapped_column(String(1000))
    warning_flags: Mapped[list[str]] = mapped_column(JSON, default=list, nullable=False)
    source_count: Mapped[int] = mapped_column(default=0, nullable=False)
    created_by: Mapped[int | None] = mapped_column(ForeignKey("users.id"))
    updated_by: Mapped[int | None] = mapped_column(ForeignKey("users.id"))
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.utcnow, onupdate=datetime.utcnow
    )
