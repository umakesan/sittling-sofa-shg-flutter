from datetime import datetime

from pydantic import BaseModel


class TimestampedResponse(BaseModel):
    id: int
    created_at: datetime
    updated_at: datetime | None = None
