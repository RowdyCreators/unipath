import os
from functools import cache

from sqlalchemy import create_engine
from sqlalchemy.engine import make_url
from sqlalchemy.exc import ArgumentError
from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    pass


@cache
def get_engine():
    database_url = os.getenv("DATABASE_URL")
    if not database_url:
        raise ArgumentError("DATABASE_URL is required")
    url = make_url(database_url)
    if url.drivername not in ("postgresql", "postgresql+psycopg"):
        raise ArgumentError("DATABASE_URL must use PostgreSQL with Psycopg")
    return create_engine(
        url.set(drivername="postgresql+psycopg"),
        pool_pre_ping=True,
        pool_timeout=3,
        connect_args={"connect_timeout": 3, "options": "-c statement_timeout=3000"},
    )
