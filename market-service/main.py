from fastapi import FastAPI, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
import boto3
import uuid
import os

import models
from database import engine, get_db

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

# S3 Configuration
S3_BUCKET = os.environ.get("AWS_S3_BUCKET_NAME", "college-app-market-images")
AWS_REGION = os.environ.get("AWS_REGION", "ap-south-1")

s3_client = boto3.client('s3', region_name=AWS_REGION)

class ProductResponse(BaseModel):
    id: int
    name: str
    price: float
    condition: str
    image_url: str

    class Config:
        orm_mode = True

@app.get("/api/market/health")
def health_check():
    return {"status": "ok"}

@app.get("/api/market", response_model=List[ProductResponse])
def get_products(db: Session = Depends(get_db)):
    return db.query(models.Product).all()

@app.post("/api/market/upload")
async def upload_image(file: UploadFile = File(...)):
    try:
        file_extension = file.filename.split('.')[-1]
        unique_filename = f"{uuid.uuid4()}.{file_extension}"
        
        s3_client.upload_fileobj(
            file.file,
            S3_BUCKET,
            unique_filename,
            ExtraArgs={'ContentType': file.content_type}
        )
        
        url = f"https://{S3_BUCKET}.s3.{AWS_REGION}.amazonaws.com/{unique_filename}"
        return {"image_url": url}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/market", response_model=ProductResponse)
def create_product(
    name: str = Form(...),
    price: float = Form(...),
    condition: str = Form(...),
    image_url: str = Form(...),
    db: Session = Depends(get_db)
):
    db_product = models.Product(name=name, price=price, condition=condition, image_url=image_url)
    db.add(db_product)
    db.commit()
    db.refresh(db_product)
    return db_product
