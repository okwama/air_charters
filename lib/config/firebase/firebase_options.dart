import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // TODO: Replace these values with your actual Firebase project values
  // You can find these in your Firebase Console under Project Settings

  static const FirebaseOptions web = FirebaseOptions(
    apiKey:
        'AIzaSyCBJ3RgGeIedtclQFN7k6OvOl-X9K1Y4Us', // Replace with your web API key
    appId:
        '1:882137488801:web:7b8d128e96f762ee59bfe0', // Replace with your web app ID
    messagingSenderId: '882137488801', // Replace with your sender ID
    projectId: 'air-charters-app', // Replace with your project ID
    authDomain:
        'air-charters-app.firebaseapp.com', // Replace with your auth domain
    storageBucket:
        'air-charters-app.firebasestorage.app', // Replace with your storage bucket
    measurementId: "G-23XSN3VYWS",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey:
        'AIzaSyDkDNVfmn_XnaGVNOiK77CEJmvX7NoLyww', // Replace with your Android API key
    appId:
        '1:882137488801:android:bfe07853fa3cc7a559bfe0', // Replace with your Android app ID
    messagingSenderId: '882137488801', // Replace with your sender ID
    projectId: 'air-charters-app', // Replace with your project ID
    storageBucket:
        'air-charters-app.firebasestorage.app', // Replace with your storage bucket
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey:
        'AIzaSyDkDNVfmn_XnaGVNOiK77CEJmvX7NoLyww', // Replace with your iOS API key
    appId:
        '1:882137488801:ios:bfe07853fa3cc7a559bfe0', // Replace with your iOS app ID
    messagingSenderId: '882137488801', // Replace with your sender ID
    projectId: 'air-charters-app', // Replace with your project ID
    storageBucket:
        'air-charters-app.firebasestorage.app', // Replace with your storage bucket
    iosClientId:
        '882137488801-abcdefghijklmnop.apps.googleusercontent.com', // Replace with your iOS client ID
    iosBundleId: 'com.cit.aircharters', // Your bundle ID
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey:
        'AIzaSyDkDNVfmn_XnaGVNOiK77CEJmvX7NoLyww', // Replace with your macOS API key
    appId:
        '1:882137488801:ios:bfe07853fa3cc7a559bfe0', // Replace with your macOS app ID
    messagingSenderId: '882137488801', // Replace with your sender ID
    projectId: 'air-charters-app', // Replace with your project ID
    storageBucket:
        'air-charters-app.firebasestorage.app', // Replace with your storage bucket
    iosClientId:
        '882137488801-abcdefghijklmnop.apps.googleusercontent.com', // Replace with your macOS client ID
    iosBundleId: 'com.cit.aircharters', // Your bundle ID
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey:
        'AIzaSyDkDNVfmn_XnaGVNOiK77CEJmvX7NoLyww', // Replace with your Windows API key
    appId:
        '1:882137488801:web:bfe07853fa3cc7a559bfe0', // Replace with your Windows app ID
    messagingSenderId: '882137488801', // Replace with your sender ID
    projectId: 'air-charters-app', // Replace with your project ID
    storageBucket:
        'air-charters-app.firebasestorage.app', // Replace with your storage bucket
  );
}
