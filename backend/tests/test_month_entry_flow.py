def test_create_month_entry_marks_warning_status_when_totals_look_suspicious(client):
    response = client.post(
        "/api/v1/month-entries",
        json={
            "group_id": 1,
            "entry_month": "2026-04-01",
            "entry_mode": "prefill",
            "savings_collected": 2000,
            "internal_loan_principal_disbursed": 6000,
            "internal_loan_interest_collected": 895,
            "to_bank": 8895,
            "from_bank": 8000,
            "sofa_loan_disbursed": 0,
            "sofa_loan_repayment": 44000,
            "sofa_loan_interest_collected": 3960,
            "notes": "seed-like sample",
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["status"] == "saved"
    assert payload["warning_flags"] == []


def test_list_month_entries_returns_newest_month_first(client):
    first = client.post(
        "/api/v1/month-entries",
        json={
            "group_id": 1,
            "entry_month": "2026-03-01",
            "entry_mode": "manual",
            "savings_collected": 1000,
            "internal_loan_principal_disbursed": 0,
            "internal_loan_interest_collected": 100,
            "to_bank": 1000,
            "from_bank": 0,
            "sofa_loan_disbursed": 0,
            "sofa_loan_repayment": 0,
            "sofa_loan_interest_collected": 0,
            "notes": "",
        },
    )
    second = client.post(
        "/api/v1/month-entries",
        json={
            "group_id": 1,
            "entry_month": "2026-04-01",
            "entry_mode": "manual",
            "savings_collected": 1200,
            "internal_loan_principal_disbursed": 0,
            "internal_loan_interest_collected": 150,
            "to_bank": 1200,
            "from_bank": 0,
            "sofa_loan_disbursed": 0,
            "sofa_loan_repayment": 0,
            "sofa_loan_interest_collected": 0,
            "notes": "",
        },
    )

    assert first.status_code == 200
    assert second.status_code == 200

    response = client.get("/api/v1/month-entries")
    assert response.status_code == 200
    payload = response.json()

    assert payload[0]["entry_month"] == "2026-04-01"
    assert payload[1]["entry_month"] == "2026-03-01"


def test_update_month_entry_recomputes_warning_flags(client):
    created = client.post(
        "/api/v1/month-entries",
        json={
            "group_id": 1,
            "entry_month": "2026-05-01",
            "entry_mode": "manual",
            "savings_collected": 1200,
            "internal_loan_principal_disbursed": 0,
            "internal_loan_interest_collected": 150,
            "to_bank": 1200,
            "from_bank": 0,
            "sofa_loan_disbursed": 0,
            "sofa_loan_repayment": 0,
            "sofa_loan_interest_collected": 0,
            "notes": "",
        },
    )
    entry_id = created.json()["id"]

    updated = client.patch(
        f"/api/v1/month-entries/{entry_id}",
        json={
            "to_bank": 3000,
            "from_bank": 500,
        },
    )

    assert updated.status_code == 200
    payload = updated.json()
    assert payload["status"] == "saved"
    assert payload["warning_flags"] == []


def test_dashboard_aggregates_totals_and_warning_count(client):
    client.post(
        "/api/v1/month-entries",
        json={
            "group_id": 1,
            "entry_month": "2026-06-01",
            "entry_mode": "manual",
            "savings_collected": 3000,
            "internal_loan_principal_disbursed": 1000,
            "internal_loan_interest_collected": 200,
            "to_bank": 3000,
            "from_bank": 0,
            "sofa_loan_disbursed": 0,
            "sofa_loan_repayment": 1000,
            "sofa_loan_interest_collected": 0,
            "notes": "",
        },
    )
    client.post(
        "/api/v1/month-entries",
        json={
            "group_id": 2,
            "entry_month": "2026-06-01",
            "entry_mode": "prefill",
            "savings_collected": 1000,
            "internal_loan_principal_disbursed": 0,
            "internal_loan_interest_collected": 100,
            "to_bank": 2000,
            "from_bank": 500,
            "sofa_loan_disbursed": 0,
            "sofa_loan_repayment": 500,
            "sofa_loan_interest_collected": 50,
            "notes": "",
        },
    )

    response = client.get("/api/v1/reports/dashboard")

    assert response.status_code == 200
    payload = response.json()
    assert payload["total_savings_collected"] == 4000
    assert payload["total_internal_loan_principal"] == 1000
    assert payload["total_internal_loan_interest"] == 300
    assert payload["total_sofa_repaid"] == 1500
    assert payload["warning_entry_count"] == 0
