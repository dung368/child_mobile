import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  static Future show(String title, String body) async {
    const android = AndroidNotificationDetails(
      'child_channel',
      'Child Alert',
      importance: Importance.max,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    await _plugin.show(
      0,
      title,
      body,
      const NotificationDetails(android: android, iOS: ios),
    );
  }
}
