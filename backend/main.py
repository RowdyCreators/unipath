from fastapi import FastAPI
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError

from database import get_engine

app = FastAPI()


@app.get("/api/health")
def health():
    return {"status": "ok"}


@app.get("/api/health/db")
def database_health():
    try:
        # Connectivity only; this does not verify schema or migrations.
        with get_engine().connect() as connection:
            connection.execute(text("SELECT 1")).scalar_one()
    except SQLAlchemyError:
        return JSONResponse(
            {"status": "error", "database": "unavailable"}, status_code=503
        )
    return {"status": "ok", "database": "ok"}


class TestBody(BaseModel):
    message: str


@app.post("/api/test")
async def test(body: TestBody):
    return {"message": f"got message: {body.message}"}
