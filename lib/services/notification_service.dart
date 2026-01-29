import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  /// Khởi tạo và đăng ký channel (gọi ở main() khi app start)
  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      // nếu bạn có custom icon, thay null bằng 'resource://drawable/res_icon'
      null,
      [
        NotificationChannel(
          channelKey: 'child_channel',
          channelName: 'Child Alerts',
          channelDescription: 'Alerts when child detected in car',
          defaultColor: Colors.deepPurple,
          ledColor: Colors.white,
          playSound: true,
          enableLights: true,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
      ],
      debug: true,
    );
  }

  /// Kiểm tra & yêu cầu quyền (Android 13+ / iOS)
  static Future<void> requestPermissionIfNeeded() async {
    final allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!allowed) {
      // Hiển thị dialog request permission; caller có thể gọi trực tiếp trước khi show notification
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  /// Hiển thị notification đơn giản
  static Future<void> show(String title, String body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'child_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }
}
