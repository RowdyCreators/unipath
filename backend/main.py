from fastapi import FastAPI, Request
from pydantic import BaseModel

app = FastAPI()


class TestBody(BaseModel):
    message: str


@app.post("/api/test")
async def test(body: TestBody):
    return {"message": f"got message: {body.message}"}
