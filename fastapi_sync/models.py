from sqlalchemy import Column, Integer, String
from dbutils import Base

class Item(Base):
    __tablename__ = "items"

    item_id = Column(Integer, primary_key=True)
    name = Column(String)
    description = Column(String)
