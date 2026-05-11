from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import db_session, require_admin
from app.models.group import Group
from app.schemas.group import GroupCreate, GroupRead


router = APIRouter()


@router.get("", response_model=list[GroupRead])
def list_groups(db: Session = Depends(db_session)) -> list[Group]:
    return db.query(Group).order_by(Group.village_name, Group.name).all()


@router.post("", response_model=GroupRead, status_code=status.HTTP_201_CREATED)
def create_group(
    payload: GroupCreate,
    db: Session = Depends(db_session),
    _: None = Depends(require_admin),
) -> Group:
    if db.query(Group).filter(Group.code == payload.code).first():
        raise HTTPException(status_code=409, detail="Group code already exists")
    group = Group(**payload.model_dump())
    db.add(group)
    db.commit()
    db.refresh(group)
    return group
