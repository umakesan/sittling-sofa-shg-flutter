"""replace village_id FK with village_name column on groups

Revision ID: b2c3d4e5f6a7
Revises: a1b2c3d4e5f6
Create Date: 2026-05-11

"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = 'b2c3d4e5f6a7'
down_revision: Union[str, Sequence[str], None] = 'a1b2c3d4e5f6'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Add village_name, copying from the villages table for any existing rows
    op.add_column('groups', sa.Column('village_name', sa.String(120), nullable=True))
    op.execute("""
        UPDATE groups g
        SET village_name = v.name
        FROM villages v
        WHERE g.village_id = v.id
    """)
    op.alter_column('groups', 'village_name', nullable=False, server_default=None)

    # Drop the FK and the old column
    op.drop_constraint('groups_village_id_fkey', 'groups', type_='foreignkey')
    op.drop_column('groups', 'village_id')

    # The villages table is no longer needed
    op.drop_table('villages')


def downgrade() -> None:
    op.create_table(
        'villages',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('name', sa.String(120), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('name'),
    )
    op.add_column('groups', sa.Column('village_id', sa.Integer(), nullable=True))
    op.drop_column('groups', 'village_name')
