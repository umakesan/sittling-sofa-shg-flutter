from datetime import datetime, timedelta

import bcrypt
from fastapi import APIRouter, Depends, HTTPException
from jose import jwt
from sqlalchemy.orm import Session

from app.api.deps import db_session
from app.core.config import settings
from app.models.user import User
from app.schemas.auth import LoginRequest, TokenResponse

router = APIRouter()


@router.post("/login", response_model=TokenResponse)
def login(payload: LoginRequest, db: Session = Depends(db_session)) -> TokenResponse:
    user = (
        db.query(User)
        .filter(User.user_id == payload.user_id, User.is_active.is_(True))
        .first()
    )
    if not user or not bcrypt.checkpw(payload.password.encode(), user.password_hash.encode()):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    expire = datetime.utcnow() + timedelta(minutes=settings.access_token_expire_minutes)
    token = jwt.encode(
        {"sub": user.user_id, "role": user.role.value, "name": user.name, "exp": expire},
        settings.jwt_secret_key,
        algorithm=settings.jwt_algorithm,
    )
    return TokenResponse(token=token, user_id=user.user_id, name=user.name, role=user.role.value)
