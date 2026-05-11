# reimport-data

Wipe the local PostgreSQL database and reimport everything from scratch: run migrations, seed users, and import the Excel savings data.

Run this whenever the DB schema changes or the Excel source data is updated.

## What this does

1. Tears down the Docker DB container and its data volume (full wipe)
2. Restarts a fresh Postgres container
3. Applies all Alembic migrations (`alembic upgrade head`)
4. Seeds users and sample groups (`seed.py`)
5. Imports historical savings data from `docs/women savings total.xlsx` (`import_savings.py`)

## Prerequisites

- Docker Desktop is running
- `docs/women savings total.xlsx` exists (the import script will fail without it)
- Backend venv is set up (`backend/.venv/`)

## Steps

### 1 — Wipe and restart the DB

```bash
docker compose down -v
docker compose up -d db
```

Wait ~3 seconds for Postgres to finish initialising before running migrations.

### 2 — Apply migrations

```bash
cd backend
source .venv/bin/activate
alembic upgrade head
```

### 3 — Seed users

```bash
python seed.py
```

### 4 — Import Excel data

```bash
python scripts/import_savings.py
```

Expected output:
```
Loading women savings total.xlsx ...
  sittilingi             -> Sittilingi               399 month-records
  ...
Total month-records to insert: 1666
Inserted 50 groups
Inserted 1666 month_entries
Done.
```

### 5 — Verify

```bash
# Quick row-count check
python -c "
from sqlalchemy import create_engine, text
from app.core.config import settings
e = create_engine(settings.database_url)
with e.connect() as c:
    for tbl in ['groups', 'month_entries', 'sofa_loan_entries']:
        n = c.execute(text(f'SELECT COUNT(*) FROM {tbl}')).scalar()
        print(f'{tbl}: {n} rows')
"
```

## Full one-liner (run from repo root)

```bash
docker compose down -v && docker compose up -d db && sleep 4 && \
cd backend && source .venv/bin/activate && \
alembic upgrade head && python seed.py && python scripts/import_savings.py
```
