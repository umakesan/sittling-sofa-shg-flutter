from datetime import datetime

from pydantic import BaseModel


class VillageCreate(BaseModel):
    name: str
    abbreviation: str | None = None


class VillageRead(BaseModel):
    id: int
    name: str
    abbreviation: str | None = None
    created_at: datetime

    model_config = {"from_attributes": True}
