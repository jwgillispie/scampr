# app/models/tree.py
from beanie import Document
from pydantic import BaseModel
from typing import List
from datetime import datetime

class Location(BaseModel):
    """Geographic location model"""
    latitude: float
    longitude: float

class Tree(Document):
    """Tree model for climbing locations"""
    name: str
    description: str
    location: Location
    address: str
    user_id: str
    user_name: str
    image_urls: List[str] = []
    difficulty: float  # 1.0 to 5.0
    tree_type: str
    height: float  # in meters
    features: List[str] = []  # e.g., ["thick_branches", "good_handholds", "scenic_view"]
    created_at: datetime = datetime.utcnow()
    climb_count: int = 0
    average_rating: float = 0.0
    
    class Settings:
        name = "trees"
        
    class Config:
        json_schema_extra = {
            "example": {
                "name": "The Old Oak",
                "description": "A magnificent old oak tree perfect for climbing",
                "location": {
                    "latitude": 37.7749,
                    "longitude": -122.4194
                },
                "address": "Golden Gate Park, San Francisco, CA",
                "user_id": "user_id_123",
                "user_name": "John Climber",
                "image_urls": ["https://example.com/tree1.jpg"],
                "difficulty": 3.5,
                "tree_type": "Oak",
                "height": 25.0,
                "features": ["thick_branches", "good_handholds"],
                "climb_count": 15,
                "average_rating": 4.2
            }
        }