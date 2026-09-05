from sqlalchemy import Column, Integer, String, Text
from database import Base

class Club(Base):
    __tablename__ = "clubs"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), index=True)
    category = Column(String(255))
    members = Column(Integer, default=0)
    description = Column(Text)
