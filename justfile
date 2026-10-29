set dotenv-load
set dotenv-required

default:
    just --list

dev: dev-postgres
    just dev-servers

[private]
[parallel]
dev-servers: dev-back dev-front

dev-front:
    npm exec -- vite --host 127.0.0.1 --port "$FRONTEND_PORT" --strictPort

dev-back:
    cd backend && uv run fastapi dev main.py --host 127.0.0.1 --port "$BACKEND_PORT"

dev-postgres:
    if docker container inspect unipath-postgres >/dev/null 2>&1; then \
        docker start unipath-postgres; \
    else \
        docker run --name unipath-postgres \
            -e POSTGRES_USER -e POSTGRES_PASSWORD -e POSTGRES_DB \
            -v pgdata:/var/lib/postgresql/data \
            -p "127.0.0.1:$POSTGRES_PORT:5432" \
            -d postgres:17; \
    fi
    @for attempt in $(seq 1 30); do \
        if docker exec unipath-postgres pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null 2>&1; then exit 0; fi; \
        sleep 1; \
    done; \
    echo "PostgreSQL did not become ready within 30 seconds" >&2; exit 1

down:
    docker stop unipath-postgres
