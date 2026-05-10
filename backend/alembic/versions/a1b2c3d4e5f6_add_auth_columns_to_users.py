"""add auth columns to users

Revision ID: a1b2c3d4e5f6
Revises: 3dab412f29c6
Create Date: 2026-05-10

"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "a1b2c3d4e5f6"
down_revision: Union[str, Sequence[str], None] = "3dab412f29c6"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "users",
        sa.Column("user_id", sa.String(50), nullable=False, server_default=""),
    )
    op.add_column(
        "users",
        sa.Column("password_hash", sa.String(255), nullable=False, server_default=""),
    )
    op.create_unique_constraint("uq_users_user_id", "users", ["user_id"])
    # Remove server defaults now that the column exists — values must be set explicitly
    op.alter_column("users", "user_id", server_default=None)
    op.alter_column("users", "password_hash", server_default=None)


def downgrade() -> None:
    op.drop_constraint("uq_users_user_id", "users", type_="unique")
    op.drop_column("users", "password_hash")
    op.drop_column("users", "user_id")
