// lib/services/notification_service.dart
import 'package:child_mobile/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Top-level background handler used by Firebase. Must be a top-level or @pragma entry-point.
  /// This will be registered in main.dart as:
  /// FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Ensure Firebase is initialized in background isolate
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Initialize local notifications plugin in background isolate
    await _initializeLocalNotification();

    // Show the incoming message as a local notification (background)
    await _showFlutterNotification(message);
  }

  /// Call at app startup (main) to configure listeners, request permissions, etc.
  static Future<void> initializeNotification() async {
    // Request permission (iOS / Android 13+)
    await _firebaseMessaging.requestPermission();

    // Initialize local notifications plugin (foreground)
    await _initializeLocalNotification();

    // Handle foreground messages: show as local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _showFlutterNotification(message);
    });

    // Tapped notification that opened the app from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("App opened from notification: ${message.data}");
      // you can navigate or handle deep links here if desired
    });

    // Handle app launched from terminated state via a notification
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      debugPrint("App launched from terminated via notification: ${initial.data}");
    }

    // Optionally obtain FCM token here if you want:
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint("FCM token (init): $token");
  }

  /// Internal helper: show a Flutter local notification built from RemoteMessage.
  static Future<void> _showFlutterNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    final Map<String, dynamic> data = message.data;

    final String title = notification?.title ?? data['title'] ?? 'Notification';
    final String body = notification?.body ?? data['body'] ?? 'You have a message';

    const String channelId = 'driver_alerts';
    const String channelName = 'Driver Alerts';
    const String channelDesc = 'Notifications about driver camera events';

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
    );

    final iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final platformDetails = NotificationDetails(android: androidDetails, iOS: iOSDetails);

    // use a timestamp-based id to avoid overwriting notifications
    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformDetails,
      payload: data.toString(),
    );
  }

  /// Public helper so other app code can show a local notification easily
  static Future<void> showLocalNotification(String title, String body) async {
    final message = RemoteMessage(notification: RemoteNotification(title: title, body: body), data: {});
    await _showFlutterNotification(message);
  }

  /// Initializes the local notification plugin (creates channel), safe to call multiple times.
  static Future<void> _initializeLocalNotification() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInit = DarwinInitializationSettings();

    final initSettings = InitializationSettings(android: androidInit, iOS: iOSInit);

    await flutterLocalNotificationsPlugin.initialize(settings: initSettings, onDidReceiveNotificationResponse: (response) {
      debugPrint("User tapped notification: ${response.payload}");
    });

    // Create Android notification channel (driver_alerts)
    const androidChannel = AndroidNotificationChannel(
      'driver_alerts', // id (must match manifest meta-data if used)
      'Driver Alerts',
      description: 'Notifications when driver camera status changes',
      importance: Importance.high,
    );

    // Register channel (only Android)
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }
}
