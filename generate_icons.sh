#!/bin/bash

echo "🚀 Flutter App Icon Generator"
echo "================================"
echo

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed"
    echo "Please install Python 3 from https://python.org"
    exit 1
fi

# Check if PIL/Pillow is installed
if ! python3 -c "import PIL" &> /dev/null; then
    echo "📦 Installing Pillow (PIL)..."
    pip3 install Pillow
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install Pillow"
        exit 1
    fi
fi

echo "🎨 Generating app icons from 'shoolin logo.jpg'..."
echo

# Run the icon generator
python3 generate_app_icons.py

echo
echo "📋 Manual steps to complete:"
echo "1. Copy generated Android icons to: android/app/src/main/res/"
echo "2. Copy generated iOS icons to: ios/Runner/Assets.xcassets/AppIcon.appiconset/"
echo "3. Clean and rebuild your Flutter app"
echo 