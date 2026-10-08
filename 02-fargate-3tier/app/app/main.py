from fastapi import FastAPI

app = FastAPI(title="fargate-3tier")

SERVICE_NAME = "fargate-3tier"


@app.get("/")
def read_root() -> dict[str, str]:
    return {"message": "Hello, world again!!", "service": SERVICE_NAME}


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}
