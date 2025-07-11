#!/bin/bash

# AirCharters Optimized Build Script
# This script builds the app with performance optimizations

echo "🚀 AirCharters Optimized Build"
echo "=============================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter not found. Please install Flutter first."
    exit 1
fi

print_status "Checking Flutter doctor..."
flutter doctor --verbose

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean
flutter pub get

print_success "Dependencies updated"

# Get build target from user input
echo ""
echo "Select build target:"
echo "1) Web (Optimized)"
echo "2) Android APK (Release)"
echo "3) iOS (Release)"
echo "4) All platforms"
echo ""
read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        print_status "Building optimized web version..."
        
        # Web build with performance optimizations
        flutter build web \
            --release \
            --web-renderer canvaskit \
            --dart-define=FLUTTER_WEB_USE_SKIA=true \
            --source-maps \
            --pwa-strategy=offline-first
        
        print_success "Web build completed!"
        print_status "Build output: build/web/"
        
        # Show bundle size
        if [ -d "build/web" ]; then
            web_size=$(du -sh build/web | cut -f1)
            print_status "Web bundle size: $web_size"
        fi
        ;;
        
    2)
        print_status "Building Android APK (Release)..."
        
        # Create debug info directory
        mkdir -p build/debug-info
        
        # Android build with obfuscation
        flutter build apk \
            --release \
            --obfuscate \
            --split-debug-info=build/debug-info/ \
            --shrink
        
        print_success "Android APK build completed!"
        print_status "APK location: build/app/outputs/flutter-apk/app-release.apk"
        
        # Show APK size
        if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
            apk_size=$(ls -lh build/app/outputs/flutter-apk/app-release.apk | awk '{print $5}')
            print_status "APK size: $apk_size"
        fi
        ;;
        
    3)
        print_status "Building iOS (Release)..."
        
        # Check if on macOS
        if [[ "$OSTYPE" != "darwin"* ]]; then
            print_error "iOS builds require macOS"
            exit 1
        fi
        
        # Create debug info directory
        mkdir -p build/debug-info
        
        # iOS build with obfuscation
        flutter build ios \
            --release \
            --obfuscate \
            --split-debug-info=build/debug-info/
        
        print_success "iOS build completed!"
        print_status "Open ios/Runner.xcworkspace in Xcode to archive and distribute"
        ;;
        
    4)
        print_status "Building all platforms..."
        
        # Create debug info directory
        mkdir -p build/debug-info
        
        # Web build
        print_status "Building web..."
        flutter build web \
            --release \
            --web-renderer canvaskit \
            --dart-define=FLUTTER_WEB_USE_SKIA=true \
            --pwa-strategy=offline-first
        
        # Android build
        print_status "Building Android..."
        flutter build apk \
            --release \
            --obfuscate \
            --split-debug-info=build/debug-info/ \
            --shrink
        
        # iOS build (only on macOS)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            print_status "Building iOS..."
            flutter build ios \
                --release \
                --obfuscate \
                --split-debug-info=build/debug-info/
        else
            print_warning "Skipping iOS build (requires macOS)"
        fi
        
        print_success "All builds completed!"
        ;;
        
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "🎯 Performance Optimization Tips:"
echo "================================"
echo "• Use 'flutter build web --analyze-size' to analyze bundle size"
echo "• Test on real devices for accurate performance metrics"
echo "• Use Flutter DevTools for performance profiling"
echo "• Monitor memory usage during development"
echo ""

print_success "Build process completed!"

# Optional: Run bundle size analysis
read -p "Run bundle size analysis? (y/N): " analyze
if [[ $analyze =~ ^[Yy]$ ]]; then
    print_status "Running bundle size analysis..."
    flutter build web --analyze-size
fi