// import 'package:flutter/material.dart';
// import 'package:workmanager/workmanager.dart';
// import 'services/notification_service.dart';
// import 'pages/login_page.dart';

// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     // Background task – sẽ gọi API /current nếu bạn cần
//     return Future.value(true);
//   });
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await NotificationService.init();
//   await Workmanager().initialize(callbackDispatcher);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Child In Car Monitor',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const LoginPage(),
//     );
//   }
// }
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'services/notification_service.dart';
import 'pages/login_page.dart';
import 'services/api_service.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Background task – try to call /current if token present.
    // Note: background isolates may have limitations for some plugins.
    try {
      // ensure token is loaded in this isolate too (loadToken uses SharedPreferences)
      await ApiService.loadToken();
      if (ApiService.token.isNotEmpty) {
        try {
          final current = await ApiService.getCurrent();
          // You can do something with 'current' here, like show a notification.
          // For example: NotificationService.showNotification(...)
          // But keep it minimal for background tasks.
          // print('Background current: $current');
        } catch (_) {
          // ignore errors in background
        }
      }
    } catch (_) {
      // ignore background initialization errors
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize notification service (your existing implementation)
  await NotificationService.init();

  // load any stored token before runApp
  await ApiService.loadToken();

  // initialize background worker
  await Workmanager().initialize(callbackDispatcher);

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
