# Scampr Backend

FastAPI + MongoDB backend for the Scampr tree climbing app.

## Features

- **Authentication**: JWT-based user authentication
- **Trees**: CRUD operations for climbing tree locations  
- **Reviews**: User reviews and ratings for trees
- **Location Search**: Find trees by distance/radius
- **User Management**: Profile management and climb tracking

## Quick Start

### Option 1: Docker (Recommended)

```bash
# Start MongoDB and API
docker-compose up

# API will be available at http://localhost:8000
```

### Option 2: Local Development

```bash
# Install dependencies
pip install -r requirements.txt

# Start MongoDB (install separately)
mongod

# Copy environment file
cp .env.example .env

# Run the API
python run.py
```

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login user

### Trees
- `GET /api/v1/trees` - Get trees (with location filtering)
- `POST /api/v1/trees` - Create tree (authenticated)
- `GET /api/v1/trees/{id}` - Get tree details
- `PUT /api/v1/trees/{id}` - Update tree (owner only)
- `DELETE /api/v1/trees/{id}` - Delete tree (owner only)

### Reviews
- `POST /api/v1/reviews` - Create review (authenticated)
- `GET /api/v1/reviews/tree/{tree_id}` - Get tree reviews
- `GET /api/v1/reviews/user/my-reviews` - Get user's reviews
- `PUT /api/v1/reviews/{id}` - Update review (author only)
- `DELETE /api/v1/reviews/{id}` - Delete review (author only)

## API Documentation

Visit http://localhost:8000/docs for interactive API documentation.

## Environment Variables

See `.env.example` for all configuration options.

## Database Schema

### Users
- email, display_name, password_hash
- climbed_trees[], added_trees[]
- profile_image_url, total_climbs

### Trees  
- name, description, location (lat/lng)
- address, difficulty, tree_type, height
- features[], image_urls[]
- climb_count, average_rating

### Reviews
- tree_id, user_id, rating, comment
- created_at