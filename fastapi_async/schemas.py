from pydantic import BaseModel

class ItemCreate(BaseModel):
    name: str
    description: str

class ItemResponse(ItemCreate):
    item_id: int

    class Config:
        from_attributes = True
