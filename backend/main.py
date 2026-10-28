from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def root(yo: int = 0, gurt: str = ""):
    return {"message": "hello from fastapi", "query": (yo, gurt)}
