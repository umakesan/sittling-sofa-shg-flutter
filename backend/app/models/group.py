from datetime import datetime

from sqlalchemy import Boolean, DateTime, ForeignKey, Numeric, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.session import Base
from app.models.village import Village


class Group(Base):
    __tablename__ = "groups"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    village_id: Mapped[int] = mapped_column(ForeignKey("villages.id"), nullable=False)
    village: Mapped[Village] = relationship("Village")
    code: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    register_template: Mapped[str] = mapped_column(String(50), default="default_v1")
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    opening_bank_balance: Mapped[float] = mapped_column(Numeric(12, 2), default=0, nullable=False)
    meeting_day: Mapped[str | None] = mapped_column(String(10), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.utcnow, onupdate=datetime.utcnow
    )
