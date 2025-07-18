#!/bin/bash

# Complete deployment script for Scampr

echo "🚀 Starting Scampr deployment..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Installing..."
    npm install -g firebase-tools
fi

# Check if logged in to Firebase
if ! firebase projects:list &> /dev/null; then
    echo "🔑 Please login to Firebase:"
    firebase login
fi

# Build the Flutter web app
echo "🔨 Building Flutter web app..."
./build_web.sh

# Deploy to Firebase Hosting
echo "🌐 Deploying to Firebase Hosting..."
firebase deploy --only hosting

echo "✅ Deployment completed!"
echo "🎉 Your app should be live at: https://scampr-trees.web.app"