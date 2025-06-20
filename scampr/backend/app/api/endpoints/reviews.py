# app/api/endpoints/reviews.py
from fastapi import APIRouter, HTTPException, status, Depends
from typing import List
from pydantic import BaseModel
from ...core.auth import get_current_user
from ...models.user import User
from ...models.tree import Tree
from ...models.review import Review

router = APIRouter()

class ReviewCreate(BaseModel):
    tree_id: str
    rating: float
    comment: str

class ReviewUpdate(BaseModel):
    rating: float
    comment: str

@router.post("/", response_model=dict)
async def create_review(review_data: ReviewCreate, current_user: User = Depends(get_current_user)):
    """Create a new review for a tree"""
    # Check if tree exists
    tree = await Tree.get(review_data.tree_id)
    if not tree:
        raise HTTPException(status_code=404, detail="Tree not found")
    
    # Check if user already reviewed this tree
    existing_review = await Review.find_one(
        Review.tree_id == review_data.tree_id,
        Review.user_id == str(current_user.id)
    )
    if existing_review:
        raise HTTPException(
            status_code=400, 
            detail="You have already reviewed this tree"
        )
    
    # Create review
    review = Review(
        tree_id=review_data.tree_id,
        user_id=str(current_user.id),
        user_name=current_user.display_name,
        rating=review_data.rating,
        comment=review_data.comment
    )
    await review.insert()
    
    # Update tree's average rating and climb count
    all_reviews = await Review.find(Review.tree_id == review_data.tree_id).to_list()
    if all_reviews:
        avg_rating = sum(r.rating for r in all_reviews) / len(all_reviews)
        tree.average_rating = round(avg_rating, 2)
        tree.climb_count = len(all_reviews)
        await tree.save()
    
    # Add tree to user's climbed_trees if not already there
    if review_data.tree_id not in current_user.climbed_trees:
        current_user.climbed_trees.append(review_data.tree_id)
        current_user.total_climbs += 1
        await current_user.save()
    
    return {"id": str(review.id), "message": "Review created successfully"}

@router.get("/tree/{tree_id}", response_model=List[dict])
async def get_tree_reviews(tree_id: str):
    """Get all reviews for a specific tree"""
    reviews = await Review.find(Review.tree_id == tree_id).to_list()
    
    return [
        {
            "id": str(review.id),
            "user_id": review.user_id,
            "user_name": review.user_name,
            "rating": review.rating,
            "comment": review.comment,
            "created_at": review.created_at
        } for review in reviews
    ]

@router.get("/user/my-reviews", response_model=List[dict])
async def get_my_reviews(current_user: User = Depends(get_current_user)):
    """Get current user's reviews"""
    reviews = await Review.find(Review.user_id == str(current_user.id)).to_list()
    
    result = []
    for review in reviews:
        # Get tree info
        tree = await Tree.get(review.tree_id)
        tree_info = {"name": "Unknown Tree"} if not tree else {"name": tree.name}
        
        result.append({
            "id": str(review.id),
            "tree_id": review.tree_id,
            "tree_name": tree_info["name"],
            "rating": review.rating,
            "comment": review.comment,
            "created_at": review.created_at
        })
    
    return result

@router.put("/{review_id}", response_model=dict)
async def update_review(review_id: str, review_data: ReviewUpdate, current_user: User = Depends(get_current_user)):
    """Update a review (only by the review's author)"""
    review = await Review.get(review_id)
    if not review:
        raise HTTPException(status_code=404, detail="Review not found")
    
    if review.user_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized to update this review")
    
    # Update review
    review.rating = review_data.rating
    review.comment = review_data.comment
    await review.save()
    
    # Update tree's average rating
    all_reviews = await Review.find(Review.tree_id == review.tree_id).to_list()
    if all_reviews:
        avg_rating = sum(r.rating for r in all_reviews) / len(all_reviews)
        tree = await Tree.get(review.tree_id)
        if tree:
            tree.average_rating = round(avg_rating, 2)
            await tree.save()
    
    return {"message": "Review updated successfully"}

@router.delete("/{review_id}")
async def delete_review(review_id: str, current_user: User = Depends(get_current_user)):
    """Delete a review (only by the review's author)"""
    review = await Review.get(review_id)
    if not review:
        raise HTTPException(status_code=404, detail="Review not found")
    
    if review.user_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized to delete this review")
    
    tree_id = review.tree_id
    await review.delete()
    
    # Update tree's average rating and climb count
    remaining_reviews = await Review.find(Review.tree_id == tree_id).to_list()
    tree = await Tree.get(tree_id)
    if tree:
        if remaining_reviews:
            avg_rating = sum(r.rating for r in remaining_reviews) / len(remaining_reviews)
            tree.average_rating = round(avg_rating, 2)
            tree.climb_count = len(remaining_reviews)
        else:
            tree.average_rating = 0.0
            tree.climb_count = 0
        await tree.save()
    
    # Remove from user's climbed_trees if no more reviews
    user_reviews = await Review.find(
        Review.user_id == str(current_user.id),
        Review.tree_id == tree_id
    ).to_list()
    
    if not user_reviews and tree_id in current_user.climbed_trees:
        current_user.climbed_trees.remove(tree_id)
        current_user.total_climbs = max(0, current_user.total_climbs - 1)
        await current_user.save()
    
    return {"message": "Review deleted successfully"}