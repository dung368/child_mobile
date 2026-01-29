import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'services/notification_service.dart';
import 'pages/login_page.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Background task – sẽ gọi API /current nếu bạn cần
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
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
