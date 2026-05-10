from datetime import datetime
from enum import Enum

from sqlalchemy import DateTime, Enum as SqlEnum, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from app.db.session import Base


class CaptureSide(str, Enum):
    COVER = "cover"
    LEDGER = "ledger"
    OTHER = "other"


class MonthEntryImage(Base):
    __tablename__ = "month_entry_images"

    id: Mapped[int] = mapped_column(primary_key=True)
    month_entry_id: Mapped[int] = mapped_column(ForeignKey("month_entries.id"), nullable=False)
    storage_path: Mapped[str] = mapped_column(String(500), nullable=False)
    original_filename: Mapped[str] = mapped_column(String(255), nullable=False)
    mime_type: Mapped[str] = mapped_column(String(100), nullable=False)
    capture_side: Mapped[CaptureSide] = mapped_column(
        SqlEnum(CaptureSide), default=CaptureSide.OTHER, nullable=False
    )
    uploaded_by: Mapped[int | None] = mapped_column(ForeignKey("users.id"))
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
