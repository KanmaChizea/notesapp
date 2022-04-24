// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB0PYoK68SKW6b3s5RoGxjK24GHTBDzbDk',
    appId: '1:382441897492:web:ddebdd05346816cbc8f101',
    messagingSenderId: '382441897492',
    projectId: 'notesapp-123kanma',
    authDomain: 'notesapp-123kanma.firebaseapp.com',
    storageBucket: 'notesapp-123kanma.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCnrrseLpXCrPPLJACdcuce2caznqWcGvg',
    appId: '1:382441897492:android:46e1b72b9dbbbbb7c8f101',
    messagingSenderId: '382441897492',
    projectId: 'notesapp-123kanma',
    storageBucket: 'notesapp-123kanma.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC2mlR8-tcF9u-ZUGCK9jyEsD2tp6HNjV4',
    appId: '1:382441897492:ios:06e04f9381d88c18c8f101',
    messagingSenderId: '382441897492',
    projectId: 'notesapp-123kanma',
    storageBucket: 'notesapp-123kanma.appspot.com',
    iosClientId: '382441897492-qadpo160pt6mh9v6omjbvq07rojo61bh.apps.googleusercontent.com',
    iosBundleId: 'com.examp',
  );
}