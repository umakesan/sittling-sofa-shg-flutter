from app.models.month_entry import EntryStatus, MonthEntry


def build_warning_flags(_entry: MonthEntry) -> list[str]:
    return []


def derive_status(_warning_flags: list[str]) -> EntryStatus:
    return EntryStatus.SAVED
