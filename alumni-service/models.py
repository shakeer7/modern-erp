from sqlalchemy import Column, Integer, String
from database import Base

class Alumni(Base):
    __tablename__ = "alumni"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), index=True)
    graduation_year = Column(Integer)
    company = Column(String(255))
    role = Column(String(255))
