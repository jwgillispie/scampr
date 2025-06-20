# app/models/user.py
from beanie import Document
from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

class User(Document):
    """User model for Scampr app"""
    email: EmailStr
    display_name: str
    password_hash: str
    firebase_uid: Optional[str] = None  # Firebase Auth UID
    profile_image_url: Optional[str] = None
    climbed_trees: List[str] = []
    added_trees: List[str] = []
    joined_date: datetime = datetime.utcnow()
    total_climbs: int = 0
    is_active: bool = True
    
    class Settings:
        name = "users"
        
    class Config:
        json_schema_extra = {
            "example": {
                "email": "user@example.com",
                "display_name": "John Doe",
                "profile_image_url": "https://example.com/avatar.jpg",
                "climbed_trees": ["tree_id_1", "tree_id_2"],
                "added_trees": ["tree_id_3"],
                "total_climbs": 5
            }
        }