#!/bin/bash

# Build script for Flutter web deployment

echo "🚀 Building Scampr for Web..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Build for web with optimizations
echo "🔨 Building for web..."
flutter build web --release \
  --web-renderer canvaskit \
  --dart-define=FLUTTER_WEB_USE_SKIA=true \
  --dart-define=FLUTTER_WEB_CANVASKIT_URL=https://unpkg.com/canvaskit-wasm@0.33.0/bin/ \
  --source-maps

echo "✅ Build completed! Files are in build/web/"

# Show build size
echo "📊 Build size:"
du -sh build/web/

echo "🌐 Ready for deployment!"