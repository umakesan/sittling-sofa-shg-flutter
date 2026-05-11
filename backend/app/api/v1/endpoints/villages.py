from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import db_session, require_admin
from app.models.village import Village
from app.schemas.village import VillageCreate, VillageRead

router = APIRouter()


@router.get("", response_model=list[VillageRead])
def list_villages(db: Session = Depends(db_session)) -> list[Village]:
    return db.query(Village).order_by(Village.name).all()


@router.post("", response_model=VillageRead, status_code=status.HTTP_201_CREATED)
def create_village(
    payload: VillageCreate,
    db: Session = Depends(db_session),
    _: None = Depends(require_admin),
) -> Village:
    if db.query(Village).filter(Village.name == payload.name).first():
        raise HTTPException(status_code=409, detail="Village already exists")
    village = Village(name=payload.name)
    db.add(village)
    db.commit()
    db.refresh(village)
    return village
