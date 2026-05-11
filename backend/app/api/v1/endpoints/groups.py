from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, contains_eager

from app.api.deps import db_session, require_admin
from app.models.group import Group
from app.models.village import Village
from app.schemas.group import GroupCreate, GroupRead

router = APIRouter()


def _to_read(g: Group) -> GroupRead:
    return GroupRead(
        id=g.id,
        name=g.name,
        village_name=g.village.name,
        village_id=g.village_id,
        code=g.code,
        register_template=g.register_template,
        is_active=g.is_active,
        meeting_day=g.meeting_day,
        created_at=g.created_at,
        updated_at=g.updated_at,
    )


@router.get("", response_model=list[GroupRead])
def list_groups(db: Session = Depends(db_session)) -> list[GroupRead]:
    groups = (
        db.query(Group)
        .join(Group.village)
        .options(contains_eager(Group.village))
        .order_by(Village.name, Group.name)
        .all()
    )
    return [_to_read(g) for g in groups]


@router.post("", response_model=GroupRead, status_code=status.HTTP_201_CREATED)
def create_group(
    payload: GroupCreate,
    db: Session = Depends(db_session),
    _: None = Depends(require_admin),
) -> GroupRead:
    if db.query(Group).filter(Group.code == payload.code).first():
        raise HTTPException(status_code=409, detail="Group code already exists")

    village = db.query(Village).filter(Village.name == payload.village_name).first()
    if not village:
        raise HTTPException(
            status_code=422,
            detail=f"Village '{payload.village_name}' not found. Create it first.",
        )

    data = payload.model_dump(exclude={"village_name"})
    group = Group(**data, village_id=village.id)
    db.add(group)
    db.commit()
    db.refresh(group)
    group.village = village
    return _to_read(group)
