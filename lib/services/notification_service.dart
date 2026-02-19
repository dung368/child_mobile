import 'package:child_mobile/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
    FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging =
    FirebaseMessaging.instance;
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler (
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await _initializeLocalNotification();
    await _showFlutterNotification(message);
  }

  static Future<void> initializeNotification() async {
    // Request permission
    await _firebaseMessaging.requestPermission();

    // Called when message is received while as is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
      await _showFlutterNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message){
      print("App opened from background notification: ${message.data}");
    });

    await _getFcmToken();
    await _initializeLocalNotification();
    await _getInitialNotification();
  }

  static Future<void> _getFcmToken() async {
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
  }

  static Future<void> _showFlutterNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    Map<String, dynamic>? data =message.data;
    
    String title = notification?.title ?? data['title'] ?? 'Untitled';
    String body = notification?.title ?? data['body'] ?? 'No Body';
    // Android config 
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'CHANNEL_ID', 
      'CHANNEL_NAME',
      channelDescription: 'Notification channel',
      priority: Priority.high,
      importance: Importance.high,
    );
    // iOS config
    DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    // Combine platform-specific settings
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );
    // Show notification
    await flutterLocalNotificationsPlugin.show(
      id: 0, // Notification ID
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }
  static Future<void> _initializeLocalNotification() async {
    const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@drawable/ic_launcher');

    const DarwinInitializationSettings iOSInit = DarwinInitializationSettings();

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iOSInit,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response){
        print("User tapped notification: ${response.payload}");
      },
    );
  }
  static Future<void> _getInitialNotification() async {
    RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();

    if (message != null) {
      print(
        "App launched from terminated state via notification: ${message.data}",
      );
    }
  }
}