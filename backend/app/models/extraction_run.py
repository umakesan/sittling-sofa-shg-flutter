from datetime import datetime
from enum import Enum

from sqlalchemy import DateTime, Enum as SqlEnum, ForeignKey, JSON, String
from sqlalchemy.orm import Mapped, mapped_column

from app.db.session import Base


class ExtractionStatus(str, Enum):
    QUEUED = "queued"
    COMPLETED = "completed"
    FAILED = "failed"


class ExtractionRun(Base):
    __tablename__ = "extraction_runs"

    id: Mapped[int] = mapped_column(primary_key=True)
    month_entry_id: Mapped[int] = mapped_column(ForeignKey("month_entries.id"), nullable=False)
    provider: Mapped[str] = mapped_column(String(100), nullable=False)
    model_name: Mapped[str] = mapped_column(String(100), nullable=False)
    status: Mapped[ExtractionStatus] = mapped_column(
        SqlEnum(ExtractionStatus), default=ExtractionStatus.QUEUED, nullable=False
    )
    raw_result: Mapped[dict] = mapped_column(JSON, default=dict, nullable=False)
    normalized_result: Mapped[dict] = mapped_column(JSON, default=dict, nullable=False)
    field_confidence: Mapped[dict] = mapped_column(JSON, default=dict, nullable=False)
    warnings: Mapped[list[str]] = mapped_column(JSON, default=list, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
