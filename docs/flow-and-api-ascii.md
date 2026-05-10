# SHG Portal Flow And API Calls

This diagram documents the currently implemented backend flow.

## 1. Create And Save Monthly Entry

```text
+------------------+
| Login Screen UI  |
| UI only for now  |
+--------+---------+
         |
         | local transition
         v
+---------------------------+
| Select Group + Month      |
| choose manual/prefill     |
+-------------+-------------+
              |
              | fill monthly totals
              v
+---------------------------+
| Review + Warning Check    |
| client shows draft values |
+-------------+-------------+
              |
              | POST /api/v1/month-entries
              | body:
              | - group_id
              | - entry_month
              | - entry_mode
              | - savings_collected
              | - internal_loan_principal_disbursed
              | - internal_loan_interest_collected
              | - to_bank
              | - from_bank
              | - sofa_loan_disbursed
              | - sofa_loan_repayment
              | - sofa_loan_interest_collected
              | - notes
              v
+---------------------------+
| FastAPI create endpoint   |
| create_month_entry()      |
+-------------+-------------+
              |
              | build_warning_flags()
              | derive_status()
              v
+---------------------------+
| PostgreSQL month_entries  |
| row saved with warnings   |
+-------------+-------------+
              |
              | response: MonthEntryRead
              v
+---------------------------+
| UI shows saved entry      |
| status or warnings        |
+---------------------------+
```

## 2. Edit Existing Monthly Entry

```text
+---------------------------+
| Entries list / detail UI  |
+-------------+-------------+
              |
              | GET /api/v1/month-entries
              v
+---------------------------+
| FastAPI list endpoint     |
| list_month_entries()      |
+-------------+-------------+
              |
              | rows ordered by entry_month desc
              v
+---------------------------+
| UI selects one entry      |
+-------------+-------------+
              |
              | PATCH /api/v1/month-entries/{entry_id}
              v
+---------------------------+
| FastAPI update endpoint   |
| update_month_entry()      |
+-------------+-------------+
              |
              | rebuild warnings + status
              v
+---------------------------+
| PostgreSQL row updated    |
+---------------------------+
```

## 3. Dashboard Summary

```text
+---------------------------+
| Dashboard screen          |
+-------------+-------------+
              |
              | GET /api/v1/reports/dashboard
              v
+---------------------------+
| FastAPI dashboard route   |
| get_dashboard()           |
+-------------+-------------+
              |
              | aggregate sums from month_entries
              | count warning-bearing rows
              v
+---------------------------+
| DashboardSummary JSON     |
+-------------+-------------+
              |
              v
+---------------------------+
| UI renders totals + count |
+---------------------------+
```

## 4. Current Implemented APIs

```text
GET    /health
GET    /api/v1/groups
POST   /api/v1/groups
GET    /api/v1/month-entries
POST   /api/v1/month-entries
GET    /api/v1/month-entries/{entry_id}
PATCH  /api/v1/month-entries/{entry_id}
GET    /api/v1/reports/dashboard
```

## 5. Planned But Not Yet Implemented

```text
POST /api/v1/month-entries/{entry_id}/images
POST /api/v1/month-entries/{entry_id}/extract
GET  /api/v1/reports/groups/{group_id}/ledger
```
