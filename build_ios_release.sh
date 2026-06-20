#!/bin/bash

# iOS Release Build Script with dSYM Generation
# This script ensures proper debug symbol generation for App Store submission

set -e  # Exit on error

echo "🧹 Cleaning previous builds..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🔨 Building iOS release IPA with debug symbols..."
flutter build ipa \
  --release \
  --obfuscate \
  --split-debug-info=./build/ios/debug_info

echo "✅ Build complete!"
echo ""
echo "📋 Next steps:"
echo "1. Open Xcode: open ios/Runner.xcworkspace"
echo "2. Verify Build Settings in Xcode:"
echo "   - Select 'Runner' target"
echo "   - Go to Build Settings"
echo "   - Search for 'Debug Information Format'"
echo "   - Ensure it's set to 'DWARF with dSYM File' for Release"
echo "3. Archive the app: Product → Archive"
echo "4. Upload to App Store Connect"
echo ""
echo "📁 Debug symbols saved to: ./build/ios/debug_info"
echo "📦 IPA file saved to: ./build/ios/ipa/"


