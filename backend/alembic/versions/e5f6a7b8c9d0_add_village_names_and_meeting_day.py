"""restore villages table with FK on groups and add meeting_day

Re-creates the villages table (dropped in b2c3d4e5f6a7), seeds it from the
distinct village_name values already stored on groups, and wires up a
village_id FK so groups are properly normalized again.

Also adds meeting_day to groups.

Revision ID: e5f6a7b8c9d0
Revises: d4e5f6a7b8c9
Create Date: 2026-05-11

"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = 'e5f6a7b8c9d0'
down_revision: Union[str, Sequence[str], None] = 'd4e5f6a7b8c9'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Re-create the villages table
    op.create_table(
        'villages',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('name', sa.String(120), nullable=False),
        sa.Column('created_at', sa.DateTime(), server_default=sa.func.now(), nullable=False),
        sa.Column('updated_at', sa.DateTime(), server_default=sa.func.now(), nullable=False),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('name'),
    )

    # 2. Seed from distinct village names already stored on groups
    op.execute("""
        INSERT INTO villages (name)
        SELECT DISTINCT village_name
        FROM groups
        WHERE village_name IS NOT NULL
        ORDER BY village_name
    """)

    # 3. Add village_id FK (nullable initially so existing rows can be backfilled)
    op.add_column('groups', sa.Column('village_id', sa.Integer(), nullable=True))
    op.create_foreign_key(
        'groups_village_id_fkey', 'groups', 'villages', ['village_id'], ['id']
    )

    # 4. Backfill village_id for every existing group
    op.execute("""
        UPDATE groups g
        SET village_id = v.id
        FROM villages v
        WHERE v.name = g.village_name
    """)

    # 5. Add meeting_day
    op.add_column('groups', sa.Column('meeting_day', sa.String(10), nullable=True))

    # 6. Make village_id NOT NULL now that every row is backfilled
    op.alter_column('groups', 'village_id', nullable=False)

    # 7. Drop the denormalised village_name column — villages table is the source of truth
    op.drop_column('groups', 'village_name')


def downgrade() -> None:
    # Restore village_name from the villages FK before dropping it
    op.add_column('groups', sa.Column('village_name', sa.String(120), nullable=True))
    op.execute("""
        UPDATE groups g
        SET village_name = v.name
        FROM villages v
        WHERE v.id = g.village_id
    """)
    op.alter_column('groups', 'village_name', nullable=False)

    op.drop_column('groups', 'meeting_day')
    op.alter_column('groups', 'village_id', nullable=True)
    op.drop_constraint('groups_village_id_fkey', 'groups', type_='foreignkey')
    op.drop_column('groups', 'village_id')
    op.drop_table('villages')
