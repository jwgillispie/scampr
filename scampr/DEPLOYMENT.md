# 🚀 Scampr Deployment Guide

## Overview
This guide will help you deploy Scampr as a web application using modern hosting platforms.

## 🏗️ Architecture
- **Frontend**: Flutter Web (hosted on Firebase Hosting)
- **Backend**: Python FastAPI (hosted on Render)
- **Database**: MongoDB (Render or MongoDB Atlas)

## 🔧 Prerequisites

### Required Tools
- Flutter SDK (latest stable)
- Docker
- Git
- Node.js (for Firebase CLI)

### Required Accounts
- [Firebase Console](https://console.firebase.google.com/)
- [Render](https://render.com/)
- [MongoDB Atlas](https://www.mongodb.com/atlas) (optional)

## 📱 Frontend Deployment (Firebase Hosting)

### 1. Install Firebase CLI
```bash
npm install -g firebase-tools
```

### 2. Login to Firebase
```bash
firebase login
```

### 3. Initialize Firebase in your project
```bash
firebase init hosting
```

### 4. Build Flutter Web
```bash
./build_web.sh
```

### 5. Deploy to Firebase
```bash
firebase deploy --only hosting
```

## 🐳 Backend Deployment (Render)

### 1. Prepare Environment Variables
Create the following environment variables in Render:

- `ENVIRONMENT=production`
- `PORT=8000`
- `MONGODB_URL=your-mongodb-connection-string`
- `JWT_SECRET=your-super-secure-jwt-secret`
- `CORS_ORIGINS=["https://your-domain.web.app"]`
- `GOOGLE_MAPS_API_KEY=your-google-maps-api-key`

### 2. Deploy to Render
1. Connect your GitHub repository to Render
2. Select "Web Service"
3. Use the provided `render.yaml` configuration
4. Deploy!

## 🗄️ Database Setup

### Option 1: MongoDB Atlas (Recommended)
1. Create a MongoDB Atlas account
2. Create a new cluster
3. Get your connection string
4. Add it to your environment variables

### Option 2: Render PostgreSQL
1. Create a PostgreSQL database on Render
2. Update your backend to use PostgreSQL instead of MongoDB

## 🔐 Security Setup

### 1. Generate JWT Secret
```bash
openssl rand -hex 32
```

### 2. Configure CORS
Update your backend CORS settings to only allow your frontend domain.

### 3. Environment Variables
Never commit `.env` files. Use your hosting platform's environment variable settings.

## 🚀 Deployment Steps

### 1. Backend First
```bash
# Navigate to backend directory
cd backend

# Test locally
docker build -t scampr-backend .
docker run -p 8000:8000 scampr-backend

# Deploy to Render (connect your repo)
```

### 2. Frontend Second
```bash
# Build and deploy frontend
./build_web.sh
firebase deploy --only hosting
```

## 🔧 Environment Configuration

### Development
- Backend: `http://localhost:8000`
- Frontend: `http://localhost:3000`

### Production
- Backend: `https://your-app.onrender.com`
- Frontend: `https://your-app.web.app`

## 📊 Monitoring

### Health Checks
- Backend: `https://your-backend.onrender.com/health`
- Frontend: Check Firebase Hosting console

### Logs
- Backend: Available in Render dashboard
- Frontend: Check browser console for errors

## 🛠️ Troubleshooting

### Common Issues

1. **CORS Errors**
   - Ensure your frontend domain is in the CORS_ORIGINS environment variable
   - Check that your backend is properly configured

2. **Database Connection**
   - Verify MongoDB connection string
   - Check network access settings in MongoDB Atlas

3. **API Keys**
   - Ensure Google Maps API key is valid
   - Check API key restrictions

### Performance Optimization

1. **Frontend**
   - Use `--dart-define` for production builds
   - Enable web renderer optimizations
   - Optimize images and assets

2. **Backend**
   - Use multiple workers in production
   - Implement proper caching
   - Add rate limiting

## 📝 Post-Deployment Checklist

- [ ] Backend API is accessible
- [ ] Frontend loads without errors
- [ ] Database connection works
- [ ] User authentication works
- [ ] Maps functionality works
- [ ] All API endpoints respond correctly
- [ ] Mobile responsiveness works
- [ ] SSL certificates are active

## 🔄 Continuous Deployment

### GitHub Actions Example
```yaml
name: Deploy to Firebase
on:
  push:
    branches: [ main ]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: subosito/flutter-action@v2
    - run: ./build_web.sh
    - uses: FirebaseExtended/action-hosting-deploy@v0
```

## 📞 Support

If you encounter issues:
1. Check the logs in your hosting platform
2. Verify all environment variables are set correctly
3. Test your API endpoints manually
4. Check browser console for frontend errors

## 🎉 Success!

Your Scampr app should now be live and accessible to users worldwide! 🌍🌲