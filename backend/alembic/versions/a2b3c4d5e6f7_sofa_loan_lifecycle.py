"""sofa loan lifecycle — new sofa_loans + sofa_loan_entries tables

Revision ID: a2b3c4d5e6f7
Revises: f6a7b8c9d0e1
Create Date: 2026-05-11

"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = 'a2b3c4d5e6f7'
down_revision: Union[str, Sequence[str], None] = 'f6a7b8c9d0e1'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Drop old sofa_loan_entries (FK was on month_entry_id / loan_slot)
    op.drop_table('sofa_loan_entries')

    # 2. Create sofa_loans
    op.create_table(
        'sofa_loans',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('group_id', sa.Integer(), nullable=False),
        sa.Column('name', sa.String(100), nullable=False),
        sa.Column('principal_amount', sa.Numeric(12, 2), nullable=False),
        sa.Column('disbursed_date', sa.Date(), nullable=False),
        sa.Column('status', sa.String(20), nullable=False, server_default='active'),
        sa.Column('closed_date', sa.Date(), nullable=True),
        sa.Column('created_by', sa.Integer(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(['group_id'], ['groups.id']),
        sa.ForeignKeyConstraint(['created_by'], ['users.id']),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('group_id', 'name', name='uq_sofaloan_group_name'),
    )

    # 3. Create new sofa_loan_entries (FK on sofa_loan_id, unique on (sofa_loan_id, entry_month))
    op.create_table(
        'sofa_loan_entries',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('sofa_loan_id', sa.Integer(), nullable=False),
        sa.Column('entry_month', sa.Date(), nullable=False),
        sa.Column('disbursed', sa.Numeric(12, 2), nullable=False, server_default='0'),
        sa.Column('repayment', sa.Numeric(12, 2), nullable=False, server_default='0'),
        sa.Column('interest_collected', sa.Numeric(12, 2), nullable=False, server_default='0'),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(['sofa_loan_id'], ['sofa_loans.id']),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('sofa_loan_id', 'entry_month', name='uq_loan_month'),
    )

    # 4. Add sofa_loan_entry_id nullable FK to month_entries
    op.add_column('month_entries', sa.Column('sofa_loan_entry_id', sa.Integer(), nullable=True))
    op.create_foreign_key(
        'fk_month_entries_sofa_loan_entry_id',
        'month_entries', 'sofa_loan_entries',
        ['sofa_loan_entry_id'], ['id'],
    )

    # 5. Drop old SOFA flat columns from month_entries
    op.drop_column('month_entries', 'sofa_loan_disbursed')
    op.drop_column('month_entries', 'sofa_loan_repayment')
    op.drop_column('month_entries', 'sofa_loan_interest_collected')


def downgrade() -> None:
    # Restore flat SOFA columns on month_entries
    op.add_column('month_entries', sa.Column('sofa_loan_disbursed', sa.Numeric(12, 2), nullable=False, server_default='0'))
    op.add_column('month_entries', sa.Column('sofa_loan_repayment', sa.Numeric(12, 2), nullable=False, server_default='0'))
    op.add_column('month_entries', sa.Column('sofa_loan_interest_collected', sa.Numeric(12, 2), nullable=False, server_default='0'))

    op.drop_constraint('fk_month_entries_sofa_loan_entry_id', 'month_entries', type_='foreignkey')
    op.drop_column('month_entries', 'sofa_loan_entry_id')

    op.drop_table('sofa_loan_entries')
    op.drop_table('sofa_loans')

    # Restore old sofa_loan_entries schema
    op.create_table(
        'sofa_loan_entries',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('month_entry_id', sa.Integer(), nullable=False),
        sa.Column('loan_slot', sa.Integer(), nullable=False),
        sa.Column('disbursed', sa.Numeric(12, 2), nullable=False, server_default='0'),
        sa.Column('repayment', sa.Numeric(12, 2), nullable=False, server_default='0'),
        sa.Column('interest_collected', sa.Numeric(12, 2), nullable=False, server_default='0'),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(['month_entry_id'], ['month_entries.id']),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('month_entry_id', 'loan_slot', name='uq_entry_slot'),
    )
