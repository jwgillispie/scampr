# app/api/endpoints/auth.py
from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.security import OAuth2PasswordRequestForm
from datetime import timedelta
from pydantic import BaseModel, EmailStr
from typing import Optional
from ...core.config import settings
from ...core.auth import create_access_token, get_password_hash, verify_password, get_current_user
from ...models.user import User
from ...models.tree import Tree
from ...models.review import Review

router = APIRouter()

class UserRegister(BaseModel):
    email: EmailStr
    password: str
    display_name: str
    firebase_uid: Optional[str] = None

class UserSync(BaseModel):
    email: EmailStr
    display_name: str
    firebase_uid: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str
    user: dict

@router.post("/register", response_model=Token)
async def register(user_data: UserRegister):
    """Register a new user"""
    # Check if user already exists
    existing_user = await User.find_one(User.email == user_data.email)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Create new user
    hashed_password = get_password_hash(user_data.password)
    user = User(
        email=user_data.email,
        display_name=user_data.display_name,
        password_hash=hashed_password,
        firebase_uid=user_data.firebase_uid
    )
    await user.insert()
    
    # Create access token
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.email}, expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": str(user.id),
            "email": user.email,
            "display_name": user.display_name,
            "profile_image_url": user.profile_image_url,
            "total_climbs": user.total_climbs
        }
    }

@router.post("/login", response_model=Token)
async def login(user_data: UserLogin):
    """Login user"""
    user = await User.find_one(User.email == user_data.email)
    if not user or not verify_password(user_data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.email}, expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": str(user.id),
            "email": user.email,
            "display_name": user.display_name,
            "profile_image_url": user.profile_image_url,
            "total_climbs": user.total_climbs
        }
    }

@router.post("/sync", response_model=Token)
async def sync_firebase_user(user_data: UserSync):
    """Sync Firebase user with backend database"""
    # Check if user already exists by email
    existing_user = await User.find_one(User.email == user_data.email)
    
    if existing_user:
        # Update existing user with Firebase UID if not set
        if not existing_user.firebase_uid:
            existing_user.firebase_uid = user_data.firebase_uid
            existing_user.display_name = user_data.display_name
            await existing_user.save()
        user = existing_user
    else:
        # Create new user (should not happen in Firebase flow, but just in case)
        user = User(
            email=user_data.email,
            display_name=user_data.display_name,
            password_hash="",  # No password for Firebase users
            firebase_uid=user_data.firebase_uid
        )
        await user.insert()
    
    # Create access token
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.email}, expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": str(user.id),
            "email": user.email,
            "display_name": user.display_name,
            "profile_image_url": user.profile_image_url,
            "total_climbs": user.total_climbs
        }
    }

@router.get("/users")
async def list_users():
    """Development endpoint to list all users"""
    users = await User.find_all().to_list()
    return [{
        "id": str(user.id),
        "email": user.email,
        "display_name": user.display_name,
        "firebase_uid": user.firebase_uid,
        "is_active": user.is_active,
        "joined_date": user.joined_date
    } for user in users]

@router.delete("/delete-account/{user_id}")
async def delete_user_account(user_id: str, current_user: User = Depends(get_current_user)):
    """Delete user account and all associated data"""
    
    # Verify the user is deleting their own account
    if str(current_user.id) != user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Can only delete your own account"
        )
    
    try:
        # Delete all reviews by this user
        await Review.find(Review.user_id == str(current_user.id)).delete()
        
        # Get all trees added by this user
        user_trees = await Tree.find(Tree.user_id == str(current_user.id)).to_list()
        
        # Delete all reviews for trees added by this user
        for tree in user_trees:
            await Review.find(Review.tree_id == tree.id).delete()
        
        # Delete all trees added by this user
        await Tree.find(Tree.user_id == str(current_user.id)).delete()
        
        # Finally, delete the user account
        await current_user.delete()
        
        return {"message": "Account deleted successfully"}
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete account: {str(e)}"
        )