# Sittilingi SHG Portal

Cloud-based portal for SHG monthly bookkeeping used by SOFA field workers in Sittilingi.

## Stack

- Frontend: React + TypeScript + Vite
- Backend: FastAPI
- Database: PostgreSQL
- Optional AI extraction: pluggable service behind FastAPI

## Product shape

- Field worker selects a group and month
- Worker either uploads register images for prefill or enters values manually
- System validates the monthly entry and shows warnings
- Worker can save even when warnings exist
- Ledger and dashboard reports are generated from normalized database records

## Repository layout

- `docs/solution-architecture.md`: product requirements, schema, APIs, screens
- `frontend/`: React app scaffold
- `backend/`: FastAPI app scaffold
- `docker-compose.yml`: local PostgreSQL setup

## Local development

### Database

```bash
docker compose up -d db
```

### Backend

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -e .
alembic upgrade head   # create tables
python seed.py         # seed groups and sample entries
uvicorn app.main:app --reload
```

### Frontend

```bash
cd frontend
npm install
npm run dev
```

## Initial priorities

1. Finish database migrations and persistence.
2. Implement auth and role-based access for field workers and admins.
3. Build the monthly entry workflow end to end before adding AI extraction.
