# app/core/database.py
from beanie import init_beanie
from motor.motor_asyncio import AsyncIOMotorClient
from typing import Optional
from .config import settings
from ..models.user import User
from ..models.tree import Tree
from ..models.review import Review
import logging

logger = logging.getLogger(__name__)

class Database:
    client: Optional[AsyncIOMotorClient] = None
    
async def init_db():
    """Initialize database connection and register models"""
    # Initialize MongoDB connection
    connection_url = settings.MONGODB_URL
    logger.info("Initializing MongoDB connection")
    
    client = AsyncIOMotorClient(connection_url)
    
    try:
        # Test the connection
        await client.admin.command('ping')
        logger.info("Successfully connected to MongoDB")
    except Exception as e:
        logger.error(f"Failed to connect to MongoDB: {e}")
        raise
    
    await init_beanie(
        database=client[settings.MONGODB_DB_NAME],
        document_models=[
            User,
            Tree,
            Review,
        ]
    )
    
    # Store the client for later access if needed
    Database.client = client
    
    return client

async def close_db():
    """Close database connection"""
    if Database.client:
        Database.client.close()