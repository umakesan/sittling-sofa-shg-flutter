"""initial

Revision ID: 3dab412f29c6
Revises:
Create Date: 2026-05-10 15:45:37.725753

"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op


revision: str = '3dab412f29c6'
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        'users',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('name', sa.String(120), nullable=False),
        sa.Column('phone', sa.String(30), nullable=True),
        sa.Column('email', sa.String(255), nullable=True),
        sa.Column('role', sa.Enum('field_worker', 'admin', name='userrole'), nullable=False),
        sa.Column('is_active', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('email'),
    )

    op.create_table(
        'villages',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('name', sa.String(120), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('name'),
    )

    op.create_table(
        'groups',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('name', sa.String(120), nullable=False),
        sa.Column('village_id', sa.Integer(), nullable=False),
        sa.Column('code', sa.String(120), nullable=False),
        sa.Column('register_template', sa.String(50), nullable=False, server_default='default_v1'),
        sa.Column('is_active', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(['village_id'], ['villages.id']),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('code'),
    )

    op.create_table(
        'month_entries',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('group_id', sa.Integer(), nullable=False),
        sa.Column('entry_month', sa.Date(), nullable=False),
        sa.Column('entry_mode', sa.Enum('manual', 'prefill', name='entrymode'), nullable=False),
        sa.Column(
            'status',
            sa.Enum('draft', 'saved', 'saved_with_warnings', 'synced', name='entrystatus'),
            nullable=False,
            server_default='draft',
        ),
        sa.Column('savings_collected', sa.Numeric(12, 2), nullable=False, server_default='0'),
        sa.Column('internal_loan_principal_disbursed', sa.Numeric(12, 2), nullable=False, server_default='0'),
        sa.Column('internal_loan_interest_collected', sa.Numeric(12, 2), nullable=False, server_default='0'),
        sa.Column('to_bank', sa.Numeric(12, 2), nullable=False, server_default='0'),
        sa.Column('from_bank', sa.Numeric(12, 2), nullable=False, server_default='0'),
        sa.Column('notes', sa.String(1000), nullable=True),
        sa.Column('warning_flags', sa.JSON(), nullable=False, server_default='[]'),
        sa.Column('source_count', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('created_by', sa.Integer(), nullable=True),
        sa.Column('updated_by', sa.Integer(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(['group_id'], ['groups.id']),
        sa.ForeignKeyConstraint(['created_by'], ['users.id']),
        sa.ForeignKeyConstraint(['updated_by'], ['users.id']),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('group_id', 'entry_month', name='uq_group_month'),
    )

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

    op.create_table(
        'month_entry_images',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('month_entry_id', sa.Integer(), nullable=False),
        sa.Column('storage_path', sa.String(500), nullable=False),
        sa.Column('original_filename', sa.String(255), nullable=False),
        sa.Column('mime_type', sa.String(100), nullable=False),
        sa.Column(
            'capture_side',
            sa.Enum('cover', 'ledger', 'other', name='captureside'),
            nullable=False,
            server_default='other',
        ),
        sa.Column('uploaded_by', sa.Integer(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(['month_entry_id'], ['month_entries.id']),
        sa.ForeignKeyConstraint(['uploaded_by'], ['users.id']),
        sa.PrimaryKeyConstraint('id'),
    )

    op.create_table(
        'extraction_runs',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('month_entry_id', sa.Integer(), nullable=False),
        sa.Column('provider', sa.String(100), nullable=False),
        sa.Column('model_name', sa.String(100), nullable=False),
        sa.Column(
            'status',
            sa.Enum('queued', 'completed', 'failed', name='extractionstatus'),
            nullable=False,
            server_default='queued',
        ),
        sa.Column('raw_result', sa.JSON(), nullable=False, server_default='{}'),
        sa.Column('normalized_result', sa.JSON(), nullable=False, server_default='{}'),
        sa.Column('field_confidence', sa.JSON(), nullable=False, server_default='{}'),
        sa.Column('warnings', sa.JSON(), nullable=False, server_default='[]'),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(['month_entry_id'], ['month_entries.id']),
        sa.PrimaryKeyConstraint('id'),
    )

    op.create_table(
        'audit_logs',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('entity_type', sa.String(100), nullable=False),
        sa.Column('entity_id', sa.String(100), nullable=False),
        sa.Column('action', sa.String(100), nullable=False),
        sa.Column('actor_user_id', sa.Integer(), nullable=True),
        sa.Column('before_data', sa.JSON(), nullable=False, server_default='{}'),
        sa.Column('after_data', sa.JSON(), nullable=False, server_default='{}'),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(['actor_user_id'], ['users.id']),
        sa.PrimaryKeyConstraint('id'),
    )


def downgrade() -> None:
    op.drop_table('audit_logs')
    op.drop_table('extraction_runs')
    op.drop_table('month_entry_images')
    op.drop_table('sofa_loan_entries')
    op.drop_table('month_entries')
    op.drop_table('groups')
    op.drop_table('villages')
    op.drop_table('users')
    op.execute("DROP TYPE IF EXISTS userrole")
    op.execute("DROP TYPE IF EXISTS entrymode")
    op.execute("DROP TYPE IF EXISTS entrystatus")
    op.execute("DROP TYPE IF EXISTS captureside")
    op.execute("DROP TYPE IF EXISTS extractionstatus")
