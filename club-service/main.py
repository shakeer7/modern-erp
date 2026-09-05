from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from pydantic import BaseModel

import models
from database import engine, get_db

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

class ClubCreate(BaseModel):
    name: str
    category: str
    description: str

class ClubResponse(BaseModel):
    id: int
    name: str
    category: str
    members: int
    description: str

    class Config:
        orm_mode = True

@app.get("/api/clubs/health")
def health_check():
    return {"status": "ok"}

@app.get("/api/clubs", response_model=List[ClubResponse])
def get_clubs(db: Session = Depends(get_db)):
    return db.query(models.Club).all()

@app.get("/api/clubs/{club_id}", response_model=ClubResponse)
def get_club(club_id: int, db: Session = Depends(get_db)):
    club = db.query(models.Club).filter(models.Club.id == club_id).first()
    if not club:
        raise HTTPException(status_code=404, detail="Club not found")
    return club

@app.post("/api/clubs", response_model=ClubResponse)
def create_club(club: ClubCreate, db: Session = Depends(get_db)):
    db_club = models.Club(name=club.name, category=club.category, description=club.description, members=1)
    db.add(db_club)
    db.commit()
    db.refresh(db_club)
    return db_club
