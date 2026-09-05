from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from pydantic import BaseModel

import models
from database import engine, get_db

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

class AlumniCreate(BaseModel):
    name: str
    graduation_year: int
    company: str
    role: str

class AlumniResponse(BaseModel):
    id: int
    name: str
    graduation_year: int
    company: str
    role: str

    class Config:
        orm_mode = True

@app.get("/api/alumni/health")
def health_check():
    return {"status": "ok"}

@app.get("/api/alumni", response_model=List[AlumniResponse])
def get_alumni(db: Session = Depends(get_db)):
    return db.query(models.Alumni).all()

@app.post("/api/alumni", response_model=AlumniResponse)
def create_alumni(alumni: AlumniCreate, db: Session = Depends(get_db)):
    db_alumni = models.Alumni(**alumni.dict())
    db.add(db_alumni)
    db.commit()
    db.refresh(db_alumni)
    return db_alumni
