from fastapi import FastAPI

app = FastAPI(title="ec2-3tier")

SERVICE_NAME = "ec2-3tier"


@app.get("/")
def read_root() -> dict[str, str]:
    return {"message": "Hello, world", "service": SERVICE_NAME}


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}
