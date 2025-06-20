# app/api/routes.py
from fastapi import APIRouter
from .endpoints import auth, trees, reviews

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])
api_router.include_router(trees.router, prefix="/trees", tags=["trees"])
api_router.include_router(reviews.router, prefix="/reviews", tags=["reviews"])