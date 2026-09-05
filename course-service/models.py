from sqlalchemy import Column, Integer, String
from database import Base

class Course(Base):
    __tablename__ = "courses"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), index=True)
    code = Column(String(50), unique=True, index=True)
    credits = Column(Integer)
    professor = Column(String(255))
