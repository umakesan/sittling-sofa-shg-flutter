# Sittilingi SHG Portal: V1 Solution Architecture

## 1. Product goal

Replace the current spreadsheet workflow with a tablet-friendly monthly ledger system for SHG groups.

The system is manual-entry first. Image-based extraction is optional and should prefill the same form rather than create a separate workflow.

## 2. Core workflow

1. Field worker signs in on tablet.
2. Worker selects `group`.
3. Worker selects `month`.
4. Worker chooses:
   - `Manual entry`
   - `Upload register images for prefill`
5. System shows monthly entry form.
6. System validates values and displays warnings if reconciliation is suspicious.
7. Worker saves entry.
8. Entry appears in ledger and dashboard even if warnings exist.

## 3. User roles

### Field Worker

- Create and edit monthly entries
- Upload register images
- Save entries with warnings
- View group ledger and dashboard

### Admin

- All field worker permissions
- Manage groups
- Correct any monthly entry
- Inspect extraction runs and audit history

## 4. Data model

The database is normalized. The Google Sheet is treated as a reporting format, not a database design.

### `users`

- `id`
- `name`
- `phone`
- `email`
- `role` (`field_worker`, `admin`)
- `is_active`
- `created_at`
- `updated_at`

### `groups`

- `id`
- `name`
- `village_name`
- `code`
- `register_template` (`default_v1`)
- `is_active`
- `created_at`
- `updated_at`

### `month_entries`

- `id`
- `group_id`
- `entry_month` (first day of month)
- `entry_mode` (`manual`, `prefill`)
- `status` (`draft`, `saved`, `saved_with_warnings`, `synced`)
- `savings_collected`
- `internal_loan_principal_disbursed`
- `internal_loan_interest_collected`
- `to_bank`
- `from_bank`
- `sofa_loan_disbursed`
- `sofa_loan_repayment`
- `sofa_loan_interest_collected`
- `notes`
- `warning_flags` (JSON array)
- `source_count`
- `created_by`
- `updated_by`
- `created_at`
- `updated_at`

Unique key:
- `(group_id, entry_month)`

### `month_entry_images`

- `id`
- `month_entry_id`
- `storage_path`
- `original_filename`
- `mime_type`
- `capture_side` (`cover`, `ledger`, `other`)
- `uploaded_by`
- `created_at`

### `extraction_runs`

- `id`
- `month_entry_id`
- `provider`
- `model_name`
- `status` (`queued`, `completed`, `failed`)
- `raw_result` (JSON)
- `normalized_result` (JSON)
- `field_confidence` (JSON)
- `warnings` (JSON)
- `created_at`

### `audit_logs`

- `id`
- `entity_type`
- `entity_id`
- `action`
- `actor_user_id`
- `before_data` (JSON)
- `after_data` (JSON)
- `created_at`

## 5. Derived reporting

Reports should be built from `month_entries`, not hand-maintained totals.

### Group Ledger

Shows one row per metric and one column per month, similar to the current spreadsheet:

- Savings present
- Internal loan principal
- Internal loan interest
- To bank
- From bank
- SOFA loan disbursed
- SOFA loan repayment
- SOFA loan interest

### Dashboard

- total savings across groups
- total internal loan principal across groups
- total internal interest across groups
- total SOFA disbursed
- total SOFA repaid
- warning entry count

## 6. Validation rules

Warnings are informational and should not block save.

### Required validations

- all numeric values must be `>= 0`
- duplicate month entry for same group is blocked unless editing existing row
- suspicious month-on-month jumps trigger warning
- extraction confidence below threshold triggers warning
- missing images for `prefill` mode triggers warning
- negative derived balance triggers warning

### Save behavior

- no warnings -> `saved`
- warnings present -> `saved_with_warnings`

## 7. API design

### Auth

- `POST /api/v1/auth/login`
- `GET /api/v1/auth/me`

### Groups

- `GET /api/v1/groups`
- `POST /api/v1/groups`
- `PATCH /api/v1/groups/{group_id}`

### Monthly entries

- `GET /api/v1/month-entries`
- `POST /api/v1/month-entries`
- `GET /api/v1/month-entries/{entry_id}`
- `PATCH /api/v1/month-entries/{entry_id}`
- `POST /api/v1/month-entries/{entry_id}/submit`

### Image upload

- `POST /api/v1/month-entries/{entry_id}/images`

### Extraction

- `POST /api/v1/month-entries/{entry_id}/extract`
- `GET /api/v1/month-entries/{entry_id}/extraction-runs`

### Reports

- `GET /api/v1/reports/dashboard`
- `GET /api/v1/reports/groups/{group_id}/ledger`

## 8. Screen flow

### Login

- simple credential login

### Home

- quick actions:
  - new month entry
  - continue drafts
  - view dashboard

### New Month Entry

- choose `group`
- choose `month`
- choose `manual` or `prefill`

### Image Upload

- attach one or more images
- show upload status
- trigger extraction

### Monthly Entry Form

- editable totals only
- source images visible
- warnings panel
- save draft / save entry

### Group Ledger

- month-wise ledger in sheet-like layout

### Dashboard

- village-wide totals and warning count

## 9. Offline strategy

V1 should support draft capture with later sync.

### Local behavior

- store draft form values locally
- store pending upload metadata locally
- mark entries as `draft` until sync succeeds

### Sync rules

- server owns final record IDs
- client uses temporary local IDs
- retries are idempotent by client submission key

## 10. Suggested implementation order

### Phase 1

- backend CRUD
- database schema and migrations
- React screens for manual monthly entry
- ledger and dashboard read views

### Phase 2

- image upload
- extraction run storage
- prefill into form

### Phase 3

- offline drafts
- sync queue
- stronger validation and audit tooling
