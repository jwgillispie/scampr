# app/api/endpoints/trees.py
from fastapi import APIRouter, HTTPException, status, Depends, Query
from typing import List, Optional
from pydantic import BaseModel
from ...core.auth import get_current_user
from ...models.user import User
from ...models.tree import Tree, Location
from ...models.review import Review
import math

router = APIRouter()

class TreeCreate(BaseModel):
    name: str
    description: str
    location: Location
    address: str
    image_urls: List[str] = []
    difficulty: float
    tree_type: str
    height: float
    features: List[str] = []

class TreeUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    difficulty: Optional[float] = None
    tree_type: Optional[str] = None
    height: Optional[float] = None
    features: Optional[List[str]] = None

def calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculate distance between two points in kilometers using Haversine formula"""
    R = 6371  # Earth's radius in kilometers
    
    lat1_rad = math.radians(lat1)
    lat2_rad = math.radians(lat2)
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    
    a = (math.sin(dlat / 2) * math.sin(dlat / 2) +
         math.cos(lat1_rad) * math.cos(lat2_rad) *
         math.sin(dlon / 2) * math.sin(dlon / 2))
    c = 2 * math.asin(math.sqrt(a))
    
    return R * c

@router.post("/", response_model=dict)
async def create_tree(tree_data: TreeCreate, current_user: User = Depends(get_current_user)):
    """Create a new tree"""
    tree = Tree(
        name=tree_data.name,
        description=tree_data.description,
        location=tree_data.location,
        address=tree_data.address,
        user_id=str(current_user.id),
        user_name=current_user.display_name,
        image_urls=tree_data.image_urls,
        difficulty=tree_data.difficulty,
        tree_type=tree_data.tree_type,
        height=tree_data.height,
        features=tree_data.features
    )
    await tree.insert()
    
    # Add tree to user's added_trees list
    current_user.added_trees.append(str(tree.id))
    await current_user.save()
    
    return {"id": str(tree.id), "message": "Tree created successfully"}

@router.get("/", response_model=List[dict])
async def get_trees(
    lat: Optional[float] = Query(None, description="Latitude for distance calculation"),
    lon: Optional[float] = Query(None, description="Longitude for distance calculation"),
    radius: Optional[float] = Query(None, description="Search radius in kilometers"),
    limit: int = Query(20, le=100),
    skip: int = Query(0, ge=0)
):
    """Get trees with optional location filtering"""
    trees = await Tree.find().skip(skip).limit(limit).to_list()
    
    result = []
    for tree in trees:
        tree_dict = {
            "id": str(tree.id),
            "name": tree.name,
            "description": tree.description,
            "location": {
                "latitude": tree.location.latitude,
                "longitude": tree.location.longitude
            },
            "address": tree.address,
            "user_id": tree.user_id,
            "user_name": tree.user_name,
            "image_urls": tree.image_urls,
            "difficulty": tree.difficulty,
            "tree_type": tree.tree_type,
            "height": tree.height,
            "features": tree.features,
            "created_at": tree.created_at,
            "climb_count": tree.climb_count,
            "average_rating": tree.average_rating
        }
        
        # Add distance if coordinates provided
        if lat is not None and lon is not None:
            distance = calculate_distance(lat, lon, tree.location.latitude, tree.location.longitude)
            tree_dict["distance"] = round(distance, 2)
            
            # Filter by radius if specified
            if radius is not None and distance > radius:
                continue
        
        result.append(tree_dict)
    
    # Sort by distance if coordinates provided
    if lat is not None and lon is not None:
        result.sort(key=lambda x: x.get("distance", float('inf')))
    
    return result

@router.get("/{tree_id}", response_model=dict)
async def get_tree(tree_id: str):
    """Get a specific tree by ID"""
    tree = await Tree.get(tree_id)
    if not tree:
        raise HTTPException(status_code=404, detail="Tree not found")
    
    # Get reviews for this tree
    reviews = await Review.find(Review.tree_id == tree_id).to_list()
    
    return {
        "id": str(tree.id),
        "name": tree.name,
        "description": tree.description,
        "location": {
            "latitude": tree.location.latitude,
            "longitude": tree.location.longitude
        },
        "address": tree.address,
        "user_id": tree.user_id,
        "user_name": tree.user_name,
        "image_urls": tree.image_urls,
        "difficulty": tree.difficulty,
        "tree_type": tree.tree_type,
        "height": tree.height,
        "features": tree.features,
        "created_at": tree.created_at,
        "climb_count": tree.climb_count,
        "average_rating": tree.average_rating,
        "reviews": [
            {
                "id": str(review.id),
                "user_name": review.user_name,
                "rating": review.rating,
                "comment": review.comment,
                "created_at": review.created_at
            } for review in reviews
        ]
    }

@router.put("/{tree_id}", response_model=dict)
async def update_tree(tree_id: str, tree_data: TreeUpdate, current_user: User = Depends(get_current_user)):
    """Update a tree (only by the tree's creator)"""
    tree = await Tree.get(tree_id)
    if not tree:
        raise HTTPException(status_code=404, detail="Tree not found")
    
    if tree.user_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized to update this tree")
    
    # Update fields if provided
    for field, value in tree_data.dict(exclude_unset=True).items():
        setattr(tree, field, value)
    
    await tree.save()
    return {"message": "Tree updated successfully"}

@router.delete("/{tree_id}")
async def delete_tree(tree_id: str, current_user: User = Depends(get_current_user)):
    """Delete a tree (only by the tree's creator)"""
    tree = await Tree.get(tree_id)
    if not tree:
        raise HTTPException(status_code=404, detail="Tree not found")
    
    if tree.user_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized to delete this tree")
    
    await tree.delete()
    
    # Remove from user's added_trees list
    if tree_id in current_user.added_trees:
        current_user.added_trees.remove(tree_id)
        await current_user.save()
    
    return {"message": "Tree deleted successfully"}