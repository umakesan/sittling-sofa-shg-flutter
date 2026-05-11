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
            "notes": "",
        },
    )

    response = client.get("/api/v1/reports/dashboard")

    assert response.status_code == 200
    payload = response.json()
    assert payload["total_savings_collected"] == 4000
    assert payload["total_internal_loan_principal"] == 1000
    assert payload["total_internal_loan_interest"] == 300
    assert payload["total_sofa_repaid"] == 0
    assert payload["warning_entry_count"] == 0


def test_sofa_loan_lifecycle(client):
    # Create a SOFA loan for group 1
    loan_resp = client.post(
        "/api/v1/groups/1/sofa-loans",
        json={"principal_amount": 50000, "disbursed_date": "2026-01-01"},
    )
    assert loan_resp.status_code == 201
    loan = loan_resp.json()
    assert loan["status"] == "active"
    assert loan["outstanding"] == 50000
    loan_id = loan["id"]

    # Second POST for same group should 409
    conflict = client.post(
        "/api/v1/groups/1/sofa-loans",
        json={"principal_amount": 30000, "disbursed_date": "2026-02-01"},
    )
    assert conflict.status_code == 409

    # Create a month entry with SOFA repayment
    entry_resp = client.post(
        "/api/v1/month-entries",
        json={
            "group_id": 1,
            "entry_month": "2026-03-01",
            "entry_mode": "manual",
            "savings_collected": 1000,
            "internal_loan_principal_disbursed": 0,
            "internal_loan_interest_collected": 0,
            "to_bank": 0,
            "from_bank": 0,
            "sofa_repayment": 10000,
        },
    )
    assert entry_resp.status_code == 200
    entry = entry_resp.json()
    assert entry["sofa_repayment"] == 10000
    assert entry["sofa_loan_entry_id"] is not None

    # Outstanding should have decreased
    loans = client.get("/api/v1/groups/1/sofa-loans").json()
    assert loans[0]["outstanding"] == 40000

    # Cannot close while outstanding > 0
    close_fail = client.post(f"/api/v1/sofa-loans/{loan_id}/close")
    assert close_fail.status_code == 422

    # Pay off remainder
    client.post(
        "/api/v1/month-entries",
        json={
            "group_id": 1,
            "entry_month": "2026-04-01",
            "entry_mode": "manual",
            "savings_collected": 0,
            "internal_loan_principal_disbursed": 0,
            "internal_loan_interest_collected": 0,
            "to_bank": 0,
            "from_bank": 0,
            "sofa_repayment": 40000,
        },
    )

    # Now close should succeed
    close_resp = client.post(f"/api/v1/sofa-loans/{loan_id}/close")
    assert close_resp.status_code == 200
    assert close_resp.json()["status"] == "closed"

    # New loan can be created now
    new_loan = client.post(
        "/api/v1/groups/1/sofa-loans",
        json={"principal_amount": 60000, "disbursed_date": "2026-05-01"},
    )
    assert new_loan.status_code == 201
