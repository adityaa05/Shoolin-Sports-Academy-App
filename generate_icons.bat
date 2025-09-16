@echo off
echo 🚀 Flutter App Icon Generator
echo ================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python is not installed or not in PATH
    echo Please install Python from https://python.org
    pause
    exit /b 1
)

REM Check if PIL/Pillow is installed
python -c "import PIL" >nul 2>&1
if errorlevel 1 (
    echo 📦 Installing Pillow (PIL)...
    pip install Pillow
    if errorlevel 1 (
        echo ❌ Failed to install Pillow
        pause
        exit /b 1
    )
)

echo 🎨 Generating app icons from "shoolin logo.jpg"...
echo.

REM Run the icon generator
python generate_app_icons.py

echo.
echo 📋 Manual steps to complete:
echo 1. Copy generated Android icons to: android/app/src/main/res/
echo 2. Copy generated iOS icons to: ios/Runner/Assets.xcassets/AppIcon.appiconset/
echo 3. Clean and rebuild your Flutter app
echo.
pause 