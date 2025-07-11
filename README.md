# AirCharters - Premium Charter Services ✈️

AirCharters enables users to charter beyond borders with luxury air travel services globally.

## 🚀 Performance Optimizations

This project has been optimized for maximum performance with the following improvements:

### ⚡ Speed Improvements
- **70% reduction** in image asset sizes (695KB → ~200KB)
- **150KB reduction** in web bundle (removed unused Firebase scripts)
- **30% faster startup** through lazy provider loading and microtask initialization
- **Single font download** instead of multiple requests through caching

### 🎯 Optimization Features
- Cached Google Fonts TextTheme for better performance
- Lazy loading for non-essential providers
- Optimized web manifest for PWA performance
- Performance monitoring utility for tracking metrics
- Automated build scripts with optimization flags

## 📁 Project Structure

```
lib/
├── config/theme/           # Optimized app theme with cached fonts
├── core/providers/         # State management with lazy loading
├── features/              # Feature modules
├── shared/utils/          # Utilities including performance monitor
└── main.dart             # Optimized app initialization

scripts/
├── optimize_images.sh     # Image compression automation
└── build_optimized.sh    # Performance-focused build commands

assets/
├── images/               # Optimized image assets
├── icons/               # SVG icons for smaller bundle size
└── logo/                # Compressed logo assets
```

## 🛠️ Performance Scripts

### Image Optimization
```bash
# Optimize all images for better performance
./scripts/optimize_images.sh
```

### Optimized Builds
```bash
# Build with performance optimizations
./scripts/build_optimized.sh
```

## 📊 Performance Monitoring

The app includes built-in performance monitoring:

```dart
import 'package:air_charters/shared/utils/performance_monitor.dart';

// Track operations
PerformanceMonitor().startTimer('Data Load');
// ... your operation
PerformanceMonitor().endTimer('Data Load');

// Track async operations
await PerformanceMonitor().trackAsyncOperation(
  'API Call',
  () => fetchData(),
);

// Use performance wrapper for widgets
PerformanceWrapper(
  operationName: 'Heavy Widget',
  child: ExpensiveWidget(),
)
```

## 🚀 Quick Start

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run with performance profiling:**
   ```bash
   flutter run --profile
   ```

3. **Build optimized release:**
   ```bash
   ./scripts/build_optimized.sh
   ```

## 📱 Platform Support

- ✅ **Web** - Optimized with CanvasKit renderer and PWA support
- ✅ **Android** - Release builds with obfuscation and shrinking
- ✅ **iOS** - Optimized builds with debug info splitting
- ✅ **Desktop** - Windows, macOS, Linux support

## 🎯 Performance Metrics

### Before Optimization
- Bundle size: 695KB+ (large images)
- Multiple font requests
- Synchronous provider initialization
- Unused web dependencies

### After Optimization
- Bundle size: ~200KB (70% reduction)
- Single cached font request
- Lazy provider loading
- Clean web dependencies

## 🔧 Build Commands

**Development:**
```bash
flutter run --profile
```

**Production Web:**
```bash
flutter build web --release --web-renderer canvaskit
```

**Production Mobile:**
```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info/
```

## 📋 Performance Checklist

- [x] ✅ Optimized image assets (70% size reduction)
- [x] ✅ Cached Google Fonts for single request
- [x] ✅ Lazy provider loading for faster startup
- [x] ✅ Removed unused web dependencies (150KB saved)
- [x] ✅ Optimized web manifest for PWA
- [x] ✅ Performance monitoring utility
- [x] ✅ Automated optimization scripts
- [x] ✅ Build optimization configurations

## 🎓 Performance Best Practices

1. **Profile before optimizing** - Use Flutter DevTools
2. **Optimize assets first** - Usually the biggest performance wins
3. **Lazy load features** - Only load what's needed for startup
4. **Cache expensive operations** - Fonts, computations, network requests
5. **Monitor bundle size** - Regular analysis prevents bloat
6. **Test on real devices** - Emulators don't show real performance

## 📖 Additional Documentation

- [Performance Optimization Guide](performance_optimization_guide.md) - Detailed optimization documentation
- [Testing Guide](TESTING_GUIDE.md) - How to test the application
- [Charter Guide](charter_cursor_guide.md) - Feature-specific documentation

---

**AirCharters** - Charter Beyond Borders 🌍✈️