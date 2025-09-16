#!/usr/bin/env python3
"""
App Icon Generator for Flutter App
Generates all required icon sizes from a source image for both Android and iOS
"""

import os
from PIL import Image, ImageOps
import sys

def create_icon_sizes(source_image_path, output_dir):
    """Generate all required icon sizes from source image"""
    
    # Check if source image exists
    if not os.path.exists(source_image_path):
        print(f"❌ Error: Source image '{source_image_path}' not found!")
        return False
    
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    try:
        # Open and process the source image
        with Image.open(source_image_path) as img:
            # Convert to RGBA if not already
            if img.mode != 'RGBA':
                img = img.convert('RGBA')
            
            # Make it square by cropping or padding
            width, height = img.size
            size = max(width, height)
            
            # Create a square canvas with transparent background
            square_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
            
            # Paste the image centered
            paste_x = (size - width) // 2
            paste_y = (size - height) // 2
            square_img.paste(img, (paste_x, paste_y))
            
            # Android icon sizes
            android_sizes = {
                'mipmap-mdpi': 48,
                'mipmap-hdpi': 72,
                'mipmap-xhdpi': 96,
                'mipmap-xxhdpi': 144,
                'mipmap-xxxhdpi': 192
            }
            
            # iOS icon sizes
            ios_sizes = {
                'Icon-App-20x20@1x': 20,
                'Icon-App-20x20@2x': 40,
                'Icon-App-20x20@3x': 60,
                'Icon-App-29x29@1x': 29,
                'Icon-App-29x29@2x': 58,
                'Icon-App-29x29@3x': 87,
                'Icon-App-40x40@1x': 40,
                'Icon-App-40x40@2x': 80,
                'Icon-App-40x40@3x': 120,
                'Icon-App-60x60@2x': 120,
                'Icon-App-60x60@3x': 180,
                'Icon-App-76x76@1x': 76,
                'Icon-App-76x76@2x': 152,
                'Icon-App-83.5x83.5@2x': 167,
                'Icon-App-1024x1024@1x': 1024
            }
            
            print("🎨 Generating Android icons...")
            for folder, size in android_sizes.items():
                folder_path = os.path.join(output_dir, 'android', folder)
                os.makedirs(folder_path, exist_ok=True)
                
                resized_img = square_img.resize((size, size), Image.Resampling.LANCZOS)
                output_path = os.path.join(folder_path, 'ic_launcher.png')
                resized_img.save(output_path, 'PNG')
                print(f"  ✅ {folder}/ic_launcher.png ({size}x{size})")
            
            print("\n🍎 Generating iOS icons...")
            for filename, size in ios_sizes.items():
                folder_path = os.path.join(output_dir, 'ios', 'AppIcon.appiconset')
                os.makedirs(folder_path, exist_ok=True)
                
                resized_img = square_img.resize((size, size), Image.Resampling.LANCZOS)
                output_path = os.path.join(folder_path, f'{filename}.png')
                resized_img.save(output_path, 'PNG')
                print(f"  ✅ {filename}.png ({size}x{size})")
            
            print(f"\n🎉 Successfully generated all app icons!")
            print(f"📁 Output directory: {output_dir}")
            print(f"\n📋 Next steps:")
            print(f"1. Copy Android icons to: android/app/src/main/res/")
            print(f"2. Copy iOS icons to: ios/Runner/Assets.xcassets/AppIcon.appiconset/")
            print(f"3. Update app name in AndroidManifest.xml if needed")
            
            return True
            
    except Exception as e:
        print(f"❌ Error generating icons: {e}")
        return False

def main():
    """Main function"""
    print("🚀 Flutter App Icon Generator")
    print("=" * 40)
    
    # Source image path
    source_image = "assets/shoolin logo.jpg"
    
    # Output directory
    output_dir = "generated_icons"
    
    print(f"📸 Source image: {source_image}")
    print(f"📁 Output directory: {output_dir}")
    print()
    
    # Generate icons
    success = create_icon_sizes(source_image, output_dir)
    
    if success:
        print(f"\n✅ Icon generation completed successfully!")
        print(f"📱 Your app is ready for new icons!")
    else:
        print(f"\n❌ Icon generation failed!")
        sys.exit(1)

if __name__ == "__main__":
    main() 