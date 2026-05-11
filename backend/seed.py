"""
Seed script — run once after migrations to populate initial reference data.

Usage:
    cd backend
    source .venv/bin/activate
    python seed.py
"""

import bcrypt

from app.db.session import SessionLocal
from app.models.group import Group
from app.models.month_entry import EntryMode, EntryStatus, MonthEntry
from app.models.user import User, UserRole
from app.models.village import Village


def _hash(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


# ── Users ─────────────────────────────────────────────────────────────────────
# Users are created manually by an admin — no sign-up in the app.
# Add real field worker accounts here before deploying.

USERS = [
    {
        "user_id": "admin",
        "password_hash": _hash("admin123"),
        "name": "Admin",
        "role": UserRole.ADMIN,
    },
    {
        "user_id": "field1",
        "password_hash": _hash("sofa1234"),
        "name": "Field Worker 1",
        "role": UserRole.FIELD_WORKER,
    },
]

# ── Groups ────────────────────────────────────────────────────────────────────

GROUPS = [
    {"name": "Iyarkai",      "village_name": "Sittilingi",  "code": "IYARKAI_SL"},
    {"name": "Sevvanthi",    "village_name": "Sittilingi",  "code": "SEV_SL"},
    {"name": "Malar Kalvi",  "village_name": "Kottai",      "code": "MAL_KT"},
    {"name": "Thozhi",       "village_name": "Vadakadu",    "code": "THO_VD"},
    {"name": "Pon Malar",    "village_name": "Malaithangi", "code": "PON_ML"},
    {"name": "Vaanavil",     "village_name": "Sittilingi",  "code": "VAN_SL"},
    {"name": "Siragugal",    "village_name": "Kottai",      "code": "SIR_KT"},
]

# ── Sample month entries (demo data — delete before production) ───────────────

from datetime import date  # noqa: E402

SAMPLE_ENTRIES = [
    {
        "group_code": "IYARKAI_SL",
        "entry_month": date(2026, 4, 1),
        "entry_mode": EntryMode.MANUAL,
        "savings_collected": 4800,
        "internal_loan_principal_disbursed": 12000,
        "internal_loan_interest_collected": 480,
        "to_bank": 5000,
        "from_bank": 0,
        "sofa_loan_disbursed": 0,
        "sofa_loan_repayment": 0,
        "sofa_loan_interest_collected": 0,
        "status": EntryStatus.SAVED,
        "warning_flags": [],
    },
    {
        "group_code": "SEV_SL",
        "entry_month": date(2026, 4, 1),
        "entry_mode": EntryMode.MANUAL,
        "savings_collected": 3600,
        "internal_loan_principal_disbursed": 8000,
        "internal_loan_interest_collected": 320,
        "to_bank": 3500,
        "from_bank": 0,
        "sofa_loan_disbursed": 5000,
        "sofa_loan_repayment": 2000,
        "sofa_loan_interest_collected": 200,
        "status": EntryStatus.SAVED,
        "warning_flags": [],
    },
    {
        "group_code": "MAL_KT",
        "entry_month": date(2026, 4, 1),
        "entry_mode": EntryMode.MANUAL,
        "savings_collected": 2400,
        "internal_loan_principal_disbursed": 6000,
        "internal_loan_interest_collected": 240,
        "to_bank": 4200,  # intentionally high — triggers warning
        "from_bank": 0,
        "sofa_loan_disbursed": 0,
        "sofa_loan_repayment": 1000,
        "sofa_loan_interest_collected": 100,
        "status": EntryStatus.SAVED_WITH_WARNINGS,
        "warning_flags": ["bank_deposit_exceeds_visible_collections"],
    },
]


def seed():
    db = SessionLocal()

    # Users — skip any that already exist by user_id
    existing_user_ids = {u.user_id for u in db.query(User.user_id).all()}
    new_users = [User(**u) for u in USERS if u["user_id"] not in existing_user_ids]
    if new_users:
        db.add_all(new_users)
        db.commit()
        print(f"  Added {len(new_users)} user(s)")
    else:
        print("  Users already seeded — skipped")

    # Villages — upsert distinct village names referenced by GROUPS
    village_names = {g["village_name"] for g in GROUPS}
    existing_villages = {v.name: v.id for v in db.query(Village).all()}
    for vname in sorted(village_names):
        if vname not in existing_villages:
            v = Village(name=vname)
            db.add(v)
    db.commit()
    village_id_map = {v.name: v.id for v in db.query(Village).all()}

    # Groups — skip any that already exist by code
    existing_codes = {g.code for g in db.query(Group.code).all()}
    new_groups = []
    for g in GROUPS:
        if g["code"] in existing_codes:
            continue
        gdata = {k: v for k, v in g.items() if k != "village_name"}
        gdata["village_id"] = village_id_map[g["village_name"]]
        new_groups.append(Group(**gdata))
    if new_groups:
        db.add_all(new_groups)
        db.commit()
        print(f"  Added {len(new_groups)} group(s)")
    else:
        print("  Groups already seeded — skipped")

    # Reload groups into a lookup map
    group_map = {g.code: g.id for g in db.query(Group).all()}

    # Sample entries — skip any that already exist for the same group + month
    added = 0
    for e in SAMPLE_ENTRIES:
        group_id = group_map.get(e["group_code"])
        if group_id is None:
            print(f"  WARNING: group code {e['group_code']} not found — skipping entry")
            continue
        exists = (
            db.query(MonthEntry)
            .filter_by(group_id=group_id, entry_month=e["entry_month"])
            .first()
        )
        if exists:
            continue
        entry_data = {k: v for k, v in e.items() if k != "group_code"}
        db.add(MonthEntry(group_id=group_id, **entry_data))
        added += 1

    if added:
        db.commit()
        print(f"  Added {added} sample entry/entries")
    else:
        print("  Sample entries already seeded — skipped")

    db.close()
    print("Done.")


if __name__ == "__main__":
    print("Seeding database...")
    seed()
