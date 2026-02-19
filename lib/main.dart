// lib/main.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'services/notification_service.dart';
import 'pages/login_page.dart';
import 'services/api_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/// Top-level background handler required by firebase_messaging.
/// It forwards to NotificationService's implementation (which takes care of init).
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) =>
    NotificationService.firebaseMessagingBackgroundHandler(message);

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Background task – call /current if token present.
    try {
      await ApiService.loadToken();
      if (ApiService.token.isNotEmpty) {
        try {
          final current = await ApiService.getCurrent();
          // optional: react to 'current' in background
        } catch (_) {}
      }
    } catch (_) {}
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load stored API token (so we can register device token if already logged in)
  await ApiService.loadToken();

  // Initialize local notification plugin + set up FCM handlers
  await NotificationService.initializeNotification();

  // Register top-level background message handler (must be top-level)
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  // Register Workmanager (optional background periodic checks)
  await Workmanager().initialize(callbackDispatcher);

  // Acquire FCM token and send it to server if logged in
  try {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      debugPrint("FCM token: $fcmToken");
      if (ApiService.token.isNotEmpty) {
        try {
          await ApiService.registerDeviceToken(fcmToken);
          debugPrint("Registered FCM token to server");
        } catch (e) {
          debugPrint("Failed to register device token on server: $e");
        }
      }
      // listen for future token refreshes and re-register when they happen
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        debugPrint("FCM token refreshed: $newToken");
        try {
          if (ApiService.token.isNotEmpty) {
            await ApiService.registerDeviceToken(newToken);
            debugPrint("Re-registered refreshed token on server");
          }
        } catch (e) {
          debugPrint("Failed to register refreshed token: $e");
        }
      });
    }
  } catch (e) {
    debugPrint("Error getting FCM token: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Child In Car Monitor',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}
