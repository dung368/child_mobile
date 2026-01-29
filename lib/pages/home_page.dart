import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'camera_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int children = 0, adults = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetch();
    timer = Timer.periodic(const Duration(minutes: 30), (_) => fetch());
  }

  void fetch() async {
    final data = await ApiService.getCurrent();
    setState(() {
      children = data['children'];
      adults = data['adults'];
    });
    if (children > 0) {
      NotificationService.show("⚠️ Cảnh báo", "Có $children trẻ trên xe!");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Column(children: [
        ListTile(title: const Text("Trẻ em"), trailing: Text("$children")),
        ListTile(title: const Text("Người lớn"), trailing: Text("$adults")),
        ElevatedButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CameraListPage())),
          child: const Text("Xem Camera"),
        )
      ]),
    );
  }
}
