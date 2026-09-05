from fastapi import FastAPI

import models
from database import engine
from routers import auth

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

app.include_router(auth.router)

@app.get("/api/auth/health")
def health_check():
    return {"status": "ok"}
