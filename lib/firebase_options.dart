import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
            'DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBkf22A8EbwyjrPOcKKvoyFXGArRxSgNHA',
    appId: '1:222964413725:ios:da3386a0cd5493e4c11df4',
    messagingSenderId: '222964413725',
    projectId: 'nshutitrack',
    storageBucket: 'nshutitrack.firebasestorage.app',
    iosClientId: '222964413725-vqfs4i1qe08kifngr4vgto6t7u5ieslr.apps.googleusercontent.com',
    iosBundleId: 'com.company.nshutitracker',
  );

  // TODO: Add your Android app in Firebase Console, download google-services.json
  // and replace these values with the ones from that file.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD-ITfyMXfqMQmm_M7Mu717oy9FYUPyYg4',
    appId: '1:222964413725:android:6a8345d47f7cb124c11df4',
    messagingSenderId: '222964413725',
    projectId: 'nshutitrack',
    storageBucket: 'nshutitrack.firebasestorage.app',
  );
}
