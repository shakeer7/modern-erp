from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from pydantic import BaseModel

import models
from database import engine, get_db

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

class CourseCreate(BaseModel):
    name: str
    code: str
    credits: int
    professor: str

class CourseResponse(BaseModel):
    id: int
    name: str
    code: str
    credits: int
    professor: str

    class Config:
        orm_mode = True

@app.get("/api/courses/health")
def health_check():
    return {"status": "ok"}

@app.get("/api/courses", response_model=List[CourseResponse])
def get_courses(db: Session = Depends(get_db)):
    return db.query(models.Course).all()

@app.post("/api/courses", response_model=CourseResponse)
def create_course(course: CourseCreate, db: Session = Depends(get_db)):
    db_course = models.Course(**course.dict())
    db.add(db_course)
    db.commit()
    db.refresh(db_course)
    return db_course
