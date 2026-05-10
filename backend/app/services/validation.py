from app.models.month_entry import EntryStatus, MonthEntry


def build_warning_flags(entry: MonthEntry) -> list[str]:
    warnings: list[str] = []
    source_count = entry.source_count or 0

    if entry.entry_mode.value == "prefill" and source_count == 0:
        warnings.append("prefill_mode_without_images")

    if entry.to_bank > (entry.savings_collected + entry.internal_loan_interest_collected + 1):
        warnings.append("bank_deposit_exceeds_visible_collections")

    if entry.from_bank > 0 and entry.to_bank == 0:
        warnings.append("bank_withdrawal_present_check_context")

    return warnings


def derive_status(warning_flags: list[str]) -> EntryStatus:
    if warning_flags:
        return EntryStatus.SAVED_WITH_WARNINGS
    return EntryStatus.SAVED
