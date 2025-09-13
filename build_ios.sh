#!/bin/bash

# iOS Build Script for Air Charters App
# This script builds the iOS app for extended testing on your device

set -e  # Exit on any error

echo "🚀 Starting iOS build process for Air Charters..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "Please run this script from the air_charters directory"
    exit 1
fi

# Step 1: Clean and get dependencies
print_status "Cleaning project and getting dependencies..."
flutter clean
flutter pub get

# Step 2: Check iOS setup
print_status "Checking iOS setup..."
if [ ! -d "ios" ]; then
    print_error "iOS directory not found. Make sure you're in the Flutter project root."
    exit 1
fi

# Step 3: Check if Xcode is available
if ! command -v xcodebuild &> /dev/null; then
    print_error "Xcode not found. Please install Xcode from the App Store."
    exit 1
fi

# Step 4: Check connected devices
print_status "Checking for connected iOS devices..."
DEVICES=$(xcrun xctrace list devices 2>/dev/null | grep "iPhone\|iPad" | grep -v "Simulator" || true)

if [ -z "$DEVICES" ]; then
    print_warning "No physical iOS devices found. Make sure your device is connected and trusted."
    print_status "Available simulators:"
    xcrun simctl list devices | grep "iPhone\|iPad" | grep "Booted\|Shutdown" || true
else
    print_success "Found connected devices:"
    echo "$DEVICES"
fi

# Step 5: Build for iOS
print_status "Building iOS app..."
flutter build ios --release --no-codesign

# Step 6: Open Xcode project for manual configuration
print_status "Opening Xcode project for final configuration..."
open ios/Runner.xcworkspace

print_success "Build process completed!"
echo ""
print_status "Next steps:"
echo "1. In Xcode, select your device from the device dropdown"
echo "2. Go to Runner > Signing & Capabilities"
echo "3. Make sure 'Automatically manage signing' is checked"
echo "4. Select your Team (you need an Apple Developer account)"
echo "5. The bundle identifier should be: com.citlogistics.aircharters"
echo "6. Click the Play button to build and run on your device"
echo ""
print_warning "For extended testing (more than 7 days):"
echo "1. You need an Apple Developer Program membership ($99/year)"
echo "2. Or use TestFlight for 90-day testing periods"
echo "3. Or reinstall the app every 7 days with a free developer account"
echo ""
print_status "To build and install directly from command line:"
echo "flutter run --release"
