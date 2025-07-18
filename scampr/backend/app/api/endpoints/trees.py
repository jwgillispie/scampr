# app/api/endpoints/trees.py
from fastapi import APIRouter, HTTPException, status, Depends, Query
from typing import List, Optional
from pydantic import BaseModel
from ...core.auth import get_current_user
from ...models.user import User
from ...models.tree import Tree, Location
from ...models.review import Review
import math
import re
from enum import Enum

router = APIRouter()

class SortBy(str, Enum):
    RELEVANCE = "relevance"
    DISTANCE = "distance"
    RATING = "rating"
    DIFFICULTY = "difficulty"
    POPULARITY = "popularity"
    RECENCY = "recency"

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

def calculate_search_score(tree: dict, query: Optional[str] = None, 
                          user_lat: Optional[float] = None, user_lon: Optional[float] = None,
                          preferred_difficulty: Optional[float] = None,
                          preferred_features: List[str] = None) -> float:
    """Calculate innovative search score prioritizing attributes and location over name"""
    score = 0.0
    
    # 1. Location Score (40% weight) - Proximity is key for tree climbing
    if user_lat is not None and user_lon is not None:
        distance = tree.get("distance", 0)
        if distance == 0:
            location_score = 1.0  # Same location
        elif distance <= 1:
            location_score = 0.9  # Within 1km
        elif distance <= 5:
            location_score = 0.7  # Within 5km
        elif distance <= 10:
            location_score = 0.5  # Within 10km
        elif distance <= 25:
            location_score = 0.3  # Within 25km
        else:
            location_score = max(0.1, 1.0 / (distance / 10))  # Inverse distance
        score += location_score * 0.4
    
    # 2. Feature Matching Score (25% weight) - Tree characteristics matter most
    feature_score = 0.0
    tree_features = tree.get("features", [])
    
    if preferred_features and tree_features:
        matched_features = set(preferred_features) & set(tree_features)
        feature_score = len(matched_features) / len(preferred_features)
    elif tree_features:
        # Bonus for having any features
        feature_score = 0.3
    
    # Semantic feature matching for query
    if query and tree_features:
        query_lower = query.lower()
        feature_matches = 0
        for feature in tree_features:
            if any(word in feature.lower() for word in query_lower.split()):
                feature_matches += 1
        if feature_matches > 0:
            feature_score += min(0.5, feature_matches * 0.2)
    
    score += feature_score * 0.25
    
    # 3. Quality Score (20% weight) - Rating and popularity
    rating_score = tree.get("average_rating", 0) / 5.0
    climb_popularity = min(1.0, tree.get("climb_count", 0) / 20.0)  # Normalize to 20 climbs
    quality_score = (rating_score * 0.7) + (climb_popularity * 0.3)
    score += quality_score * 0.2
    
    # 4. Difficulty Match Score (10% weight) - Appropriate challenge level
    difficulty_score = 0.5  # Neutral
    if preferred_difficulty is not None:
        tree_difficulty = tree.get("difficulty", 3.0)
        diff_gap = abs(tree_difficulty - preferred_difficulty)
        if diff_gap <= 0.5:
            difficulty_score = 1.0
        elif diff_gap <= 1.0:
            difficulty_score = 0.8
        elif diff_gap <= 1.5:
            difficulty_score = 0.6
        else:
            difficulty_score = 0.3
    score += difficulty_score * 0.1
    
    # 5. Content Relevance Score (5% weight) - Tree type and description
    content_score = 0.0
    if query:
        query_lower = query.lower()
        # Tree type matching (higher priority than name)
        tree_type = tree.get("tree_type", "").lower()
        if query_lower in tree_type or tree_type in query_lower:
            content_score += 0.4
        
        # Description matching (environmental context)
        description = tree.get("description", "").lower()
        query_words = query_lower.split()
        desc_matches = sum(1 for word in query_words if word in description)
        if desc_matches > 0:
            content_score += min(0.4, desc_matches * 0.1)
        
        # Name matching (lowest priority)
        name = tree.get("name", "").lower()
        if query_lower in name:
            content_score += 0.2
    
    score += content_score * 0.05
    
    return min(1.0, score)  # Cap at 1.0

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

@router.get("/search", response_model=List[dict])
async def search_trees(
    query: Optional[str] = Query(None, description="Search query for tree characteristics"),
    lat: Optional[float] = Query(None, description="User latitude for location scoring"),
    lon: Optional[float] = Query(None, description="User longitude for location scoring"),
    radius: Optional[float] = Query(50, description="Search radius in kilometers"),
    tree_type: Optional[str] = Query(None, description="Filter by tree type"),
    difficulty_min: Optional[float] = Query(None, description="Minimum difficulty"),
    difficulty_max: Optional[float] = Query(None, description="Maximum difficulty"),
    preferred_difficulty: Optional[float] = Query(None, description="Preferred difficulty for scoring"),
    features: Optional[str] = Query(None, description="Comma-separated list of desired features"),
    sort_by: SortBy = Query(SortBy.RELEVANCE, description="Sort results by"),
    limit: int = Query(20, le=100),
    skip: int = Query(0, ge=0)
):
    """Innovative search prioritizing tree attributes and location over name"""
    
    # Parse preferred features
    preferred_features = []
    if features:
        preferred_features = [f.strip() for f in features.split(",")]
    
    # Build base query
    trees = await Tree.find().to_list(1000)  # Get more for better scoring
    
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
        
        # Calculate distance if coordinates provided
        if lat is not None and lon is not None:
            distance = calculate_distance(lat, lon, tree.location.latitude, tree.location.longitude)
            tree_dict["distance"] = round(distance, 2)
            
            # Filter by radius
            if radius is not None and distance > radius:
                continue
        
        # Apply filters
        if tree_type and tree.tree_type.lower() != tree_type.lower():
            continue
            
        if difficulty_min is not None and tree.difficulty < difficulty_min:
            continue
            
        if difficulty_max is not None and tree.difficulty > difficulty_max:
            continue
        
        # Calculate innovative search score
        search_score = calculate_search_score(
            tree_dict, 
            query=query,
            user_lat=lat,
            user_lon=lon,
            preferred_difficulty=preferred_difficulty,
            preferred_features=preferred_features
        )
        tree_dict["search_score"] = round(search_score, 3)
        
        result.append(tree_dict)
    
    # Sort results based on sort_by parameter
    if sort_by == SortBy.RELEVANCE:
        result.sort(key=lambda x: x["search_score"], reverse=True)
    elif sort_by == SortBy.DISTANCE and lat is not None and lon is not None:
        result.sort(key=lambda x: x.get("distance", float('inf')))
    elif sort_by == SortBy.RATING:
        result.sort(key=lambda x: x["average_rating"], reverse=True)
    elif sort_by == SortBy.DIFFICULTY:
        result.sort(key=lambda x: x["difficulty"])
    elif sort_by == SortBy.POPULARITY:
        result.sort(key=lambda x: x["climb_count"], reverse=True)
    elif sort_by == SortBy.RECENCY:
        result.sort(key=lambda x: x["created_at"], reverse=True)
    
    # Apply pagination
    return result[skip:skip + limit]

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