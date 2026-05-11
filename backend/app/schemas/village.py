from datetime import datetime

from pydantic import BaseModel


class VillageCreate(BaseModel):
    name: str


class VillageRead(BaseModel):
    id: int
    name: str
    created_at: datetime

    model_config = {"from_attributes": True}
