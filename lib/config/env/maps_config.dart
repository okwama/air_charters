import 'package:flutter/foundation.dart';

class MapsConfig {
  // Google Maps API Key - Same key for all platforms
  static const String googleMapsApiKey = 'AIzaSyBzpiSxV0McO2HxL6ulP5wCjpx50xkEo_0';
  
  // Platform-specific API keys (if needed)
  static const String googleMapsApiKeyAndroid = 'AIzaSyBzpiSxV0McO2HxL6ulP5wCjpx50xkEo_0';
  static const String googleMapsApiKeyIOS = 'AIzaSyBzpiSxV0McO2HxL6ulP5wCjpx50xkEo_0';
  static const String googleMapsApiKeyWeb = 'AIzaSyBzpiSxV0McO2HxL6ulP5wCjpx50xkEo_0';
  
  // Get the appropriate API key for the current platform
  static String get apiKey {
    if (kIsWeb) {
      return googleMapsApiKeyWeb;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return googleMapsApiKeyAndroid;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return googleMapsApiKeyIOS;
    }
    return googleMapsApiKey; // fallback
  }
  
  // Map Configuration
  static const double defaultZoom = 10.0;
  static const double minZoom = 3.0;
  static const double maxZoom = 20.0;
  
  // Default center (Nairobi, Kenya)
  static const double defaultLatitude = -1.2921;
  static const double defaultLongitude = 36.8219;
  
  // Search Configuration
  static const int searchRadius = 2000000; // 2000km for air travel
  static const String defaultSearchType = 'establishment';
  
  // Map Styles
  static const String mapStyle = '''
    [
      {
        "featureType": "all",
        "elementType": "geometry.fill",
        "stylers": [
          {
            "weight": "2.00"
          }
        ]
      },
      {
        "featureType": "all",
        "elementType": "geometry.stroke",
        "stylers": [
          {
            "color": "#9c9c9c"
          }
        ]
      },
      {
        "featureType": "all",
        "elementType": "labels.text",
        "stylers": [
          {
            "visibility": "on"
          }
        ]
      },
      {
        "featureType": "landscape",
        "elementType": "all",
        "stylers": [
          {
            "color": "#f2f2f2"
          }
        ]
      },
      {
        "featureType": "landscape",
        "elementType": "geometry.fill",
        "stylers": [
          {
            "color": "#ffffff"
          }
        ]
      },
      {
        "featureType": "landscape.man_made",
        "elementType": "geometry.fill",
        "stylers": [
          {
            "color": "#ffffff"
          }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "all",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "all",
        "stylers": [
          {
            "saturation": -100
          },
          {
            "lightness": 45
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry.fill",
        "stylers": [
          {
            "color": "#eeeeee"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#7b7b7b"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#ffffff"
          }
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "all",
        "stylers": [
          {
            "visibility": "simplified"
          }
        ]
      },
      {
        "featureType": "road.arterial",
        "elementType": "labels.icon",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "transit",
        "elementType": "all",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "all",
        "stylers": [
          {
            "color": "#46bcec"
          },
          {
            "visibility": "on"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry.fill",
        "stylers": [
          {
            "color": "#c8d7d4"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#070707"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#ffffff"
          }
        ]
      }
    ]
  ''';
}
