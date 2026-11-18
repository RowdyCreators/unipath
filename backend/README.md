# UniPath API

The backend uses FastAPI. Both health endpoints are public:

- `GET /api/health`: database-independent liveness; HTTP 200 with
  `{"status":"ok"}`.
- `GET /api/health/db`: runs `SELECT 1` against PostgreSQL using `DATABASE_URL`;
  HTTP 200 with `{"status":"ok","database":"ok"}`, or HTTP 503 with
  `{"status":"error","database":"unavailable"}` if configuration is missing or
  a database operation fails. Connection details are not returned.

The database check returns its connection to the shared SQLAlchemy pool afterward
and uses three-second pool, connection, and statement timeouts. It checks connectivity, not schema or
migration readiness. Export `DATABASE_URL` before starting FastAPI, or use the
root `justfile`, which loads `.env`.

Run the isolated health tests from `backend/`:

```sh
uv run python -m unittest test_health test_database -v
```

## Database and migrations

`database.py` provides the shared SQLAlchemy engine and declarative `Base`.
Psycopg 3 remains the PostgreSQL driver. `DATABASE_URL` accepts
`postgresql://...` or `postgresql+psycopg://...`; the engine selects Psycopg
explicitly and checks pooled connections before reuse.

Define models using `Base` and import their modules in `migrations/env.py`.
There are no application tables or revisions yet. Schema changes belong in
reviewed Alembic revisions, not startup `create_all()` calls.

From `backend/`, with `DATABASE_URL` exported (or use `--env-file ../.env`):

```sh
uv run --env-file ../.env alembic revision --autogenerate -m "describe schema change"
# Review the generated upgrade and downgrade operations before applying.
uv run --env-file ../.env alembic upgrade head
uv run --env-file ../.env alembic check
```

The tests use isolated SQLite and mocks to check query/migration plumbing, not
PostgreSQL compatibility. Run migrations against a dedicated PostgreSQL database
before deployment. `alembic upgrade head` currently only initializes Alembic's
version table; it does not create application tables.
