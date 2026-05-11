from collections.abc import Generator

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

from app.api.deps import db_session
from app.db.base import Group, MonthEntry, User
from app.db.session import Base
from app.main import app
from app.models.user import UserRole
from app.models.village import Village


@pytest.fixture()
def db() -> Generator[Session, None, None]:
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
        future=True,
    )
    TestingSessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
    Base.metadata.create_all(bind=engine)

    session = TestingSessionLocal()
    village = Village(name="Sittilingi")
    session.add(village)
    session.flush()
    session.add_all(
        [
            User(user_id="field1", password_hash="x", name="Field Worker", role=UserRole.FIELD_WORKER),
            Group(name="Iyarkai - SL-13", village_id=village.id, code="IYARKAI_SL_13"),
            Group(name="Sevvanthi - SL-13", village_id=village.id, code="SEV_SL_13"),
        ]
    )
    session.commit()

    try:
        yield session
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)


@pytest.fixture()
def client(db: Session) -> Generator[TestClient, None, None]:
    def override_db():
        try:
            yield db
        finally:
            pass

    original_startup = list(app.router.on_startup)
    app.router.on_startup.clear()
    app.dependency_overrides[db_session] = override_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()
    app.router.on_startup[:] = original_startup
