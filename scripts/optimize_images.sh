#!/bin/bash

# AirCharters Image Optimization Script
# This script optimizes images for better performance

echo "🖼️  AirCharters Image Optimization"
echo "=================================="

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "❌ ImageMagick not found. Installing..."
    sudo apt-get update && sudo apt-get install -y imagemagick
fi

# Create backup directory
mkdir -p assets/optimized_images
mkdir -p assets/optimized_logo

echo "📁 Creating backups..."

# Backup original files if not already backed up
if [ ! -f "assets/images/bg_image_original.png" ]; then
    cp assets/images/bg_image.png assets/images/bg_image_original.png
    echo "✅ Backed up bg_image.png"
fi

if [ ! -f "assets/logo/logo_original.png" ]; then
    cp assets/logo/logo.png assets/logo/logo_original.png
    echo "✅ Backed up logo.png"
fi

echo "🔧 Optimizing images..."

# Optimize background image
# Reduce size while maintaining quality
convert assets/images/bg_image_original.png \
    -quality 75 \
    -resize 1920x1080> \
    -strip \
    assets/images/bg_image.png

echo "✅ Optimized background image"

# Optimize logo
# Resize to reasonable dimensions
convert assets/logo/logo_original.png \
    -quality 85 \
    -resize 512x512> \
    -strip \
    assets/logo/logo.png

echo "✅ Optimized logo"

# Create WebP versions for web
echo "🌐 Creating WebP versions for web..."

convert assets/images/bg_image_original.png \
    -quality 80 \
    -resize 1920x1080> \
    assets/images/bg_image.webp

convert assets/logo/logo_original.png \
    -quality 85 \
    -resize 512x512> \
    assets/logo/logo.webp

echo "✅ Created WebP versions"

# Show file size comparison
echo ""
echo "📊 File Size Comparison:"
echo "========================"

if [ -f "assets/images/bg_image_original.png" ]; then
    original_bg=$(stat -c%s "assets/images/bg_image_original.png")
    optimized_bg=$(stat -c%s "assets/images/bg_image.png")
    bg_savings=$((100 - (optimized_bg * 100 / original_bg)))
    
    echo "Background Image:"
    echo "  Original:  $(numfmt --to=iec $original_bg)"
    echo "  Optimized: $(numfmt --to=iec $optimized_bg)"
    echo "  Savings:   ${bg_savings}%"
fi

if [ -f "assets/logo/logo_original.png" ]; then
    original_logo=$(stat -c%s "assets/logo/logo_original.png")
    optimized_logo=$(stat -c%s "assets/logo/logo.png")
    logo_savings=$((100 - (optimized_logo * 100 / original_logo)))
    
    echo "Logo:"
    echo "  Original:  $(numfmt --to=iec $original_logo)"
    echo "  Optimized: $(numfmt --to=iec $optimized_logo)"
    echo "  Savings:   ${logo_savings}%"
fi

echo ""
echo "✨ Image optimization complete!"
echo "💡 Consider using WebP images for web builds for additional savings."