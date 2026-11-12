# Glossary

Domain language of the Sittilingi SHG Portal. Use these terms in issues, tests, and code.

**SHG (Self-Help Group)** — A village women's savings group that keeps a monthly register of savings and loans. Stored as `Group` (`backend/app/models/group.py`, `frontend/lib/models/group.dart`). _Avoid_: "team", "club".

**SOFA** — The federation/NGO the field workers belong to; it lends to SHGs and is the org the portal serves. Appears as the `sofa_*` columns and the SOFA reports (`frontend/lib/screens/reports/sofa_loans_screen.dart`).

**Field worker** — A SOFA staff member who visits groups and keys in their monthly registers, often offline. Role `field_worker` (`backend/app/models/user.py`, `frontend/lib/models/app_user.dart`).

**Admin** — Role `admin`; may create villages and groups, and sees the audit log. Enforced server-side only for admin-only endpoints (`backend/app/api/deps.py`).

**Management** — A frontend-only role (`isManagement` in `app_user.dart`) with access to comparison, trend and recovery reports. The backend `UserRole` enum has no such value.

**Village** — A place that holds several groups, with a unique name and optional `abbreviation` (`backend/app/models/village.py`). Groups reference it by `village_id`; the API accepts `village_name`.

**Group code** — Unique short identifier for a group (`Group.code`).

**Meeting day** — The weekday a group meets (`Group.meeting_day`, nullable).

**Opening bank balance** — A group's bank balance before the first recorded month (`Group.opening_bank_balance`); the starting point of the cumulative bank ledger (`GroupBankScreen`).

**Month entry** — One group's bookkeeping record for one calendar month; unique per `(group_id, entry_month)` (`backend/app/models/month_entry.py`, `frontend/lib/models/month_entry.dart`). The unit that is created on-device and synced.

**Entry mode** — How a month entry was captured: `manual` (typed) or `prefill` (prefilled from register images; image extraction is not built yet).

**Entry status** — Lifecycle of a month entry: `draft`, `saved`, `saved_with_warnings`, `synced`.

**Savings collected** — Member savings gathered in the month (`savings_collected`). Historical correction rows can be negative.

**Savings corpus** — Cumulative savings collected across months; shown on the dashboard. With interest earned it makes the **total savings asset**.

**Internal loan** — A loan the group makes to its own members from pooled savings. `internal_loan_principal_disbursed` is principal lent that month; `internal_loan_interest_collected` is interest received.

**Interest earned** — Total internal-loan interest collected; has its own drill-down report (`/reports/interest`).

**To bank / From bank** — Cash deposited into (`to_bank`) or withdrawn from (`from_bank`) the group's bank account in the month. Drive the Bank Flow reports.

**SOFA loan** — A loan from SOFA to a group, with a name, principal amount, disbursed date, and status `active` or closed (`backend/app/models/sofa_loan.py`, `frontend/lib/models/sofa_loan.dart`). A group may hold several, unique by `(group_id, name)`.

**SOFA loan lifecycle** — A SOFA loan is disbursed, accrues monthly repayments and interest as SOFA loan entries, and is closed (`closed_date`) when repaid. Introduced in migration `a2b3c4d5e6f7`.

**SOFA loan entry** — A loan's monthly `disbursed`, `repayment` and `interest_collected` amounts, unique per `(sofa_loan_id, entry_month)` (`sofa_loan_entry.py`). Month entries also carry flat `sofa_loan_disbursed`, `sofa_loan_repayment`, `sofa_loan_interest_collected` totals.

**Recovery rate** — SOFA repaid ÷ SOFA disbursed, as a percentage (`recoveryPct` in `frontend/lib/providers/reports_provider.dart`).

**Regularity** — Share of expected months for which a group has an entry (`regularityPct`); drives the Group Health report.

**Overdue** — A group with no entry in the last two months of the global range (`isOverdue` in `reports_provider.dart`).

**Warning flags** — Advisory validation markers on a month entry (`warning_flags`); never block saving. Specified in `docs/warning-logic.txt`; the backend check is currently a stub (`backend/app/services/validation.py`).

**Sync** — Pushing `pending_sync` month entries from the device's local database to the API when a worker taps Sync (`frontend/lib/database/sync_service.dart`). Native only.

**localId / serverId** — `localId` is the permanent on-device UUID key of an entry; `serverId` is set only after a successful sync.

**Audit log** — Admin-only record of entry changes with before and after data (`backend/app/models/audit_log.py`, `/reports/audit`).

**Report** — One of the nine role-filtered dashboard views computed client-side from groups and entries (`frontend/lib/providers/reports_provider.dart`).
