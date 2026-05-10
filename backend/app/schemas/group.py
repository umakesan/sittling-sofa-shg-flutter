from datetime import datetime

from pydantic import BaseModel


class GroupBase(BaseModel):
    name: str
    village_name: str
    code: str
    register_template: str = "default_v1"
    is_active: bool = True


class GroupCreate(GroupBase):
    pass


class GroupUpdate(BaseModel):
    name: str | None = None
    village_name: str | None = None
    register_template: str | None = None
    is_active: bool | None = None


class GroupRead(GroupBase):
    id: int
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
