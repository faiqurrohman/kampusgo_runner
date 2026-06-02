import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyDNeE42iOORr5Px4fcLS_2QXeCnOVuW5pY',
      appId: '1:720464757553:web:2970f16214a0306ad1e610',
      messagingSenderId: '720464757553',
      projectId: 'kampusgo-app',
      authDomain: 'kampusgo-app.firebaseapp.com',
      storageBucket: 'kampusgo-app.firebasestorage.app',
      measurementId: 'G-M4X5PGPVVJ',
    );
  }
}
