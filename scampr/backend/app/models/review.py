# app/models/review.py
from beanie import Document
from pydantic import BaseModel
from datetime import datetime

class Review(Document):
    """Review model for tree climbing reviews"""
    tree_id: str
    user_id: str
    user_name: str
    rating: float  # 1.0 to 5.0
    comment: str
    created_at: datetime = datetime.utcnow()
    
    class Settings:
        name = "reviews"
        
    class Config:
        json_schema_extra = {
            "example": {
                "tree_id": "tree_id_123",
                "user_id": "user_id_456",
                "user_name": "Jane Climber",
                "rating": 4.5,
                "comment": "Amazing tree! Great for beginners and has beautiful views.",
                "created_at": "2023-12-06T10:00:00Z"
            }
        }