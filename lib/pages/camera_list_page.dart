import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'camera_view_page.dart';

class CameraListPage extends StatefulWidget {
  const CameraListPage({super.key});
  @override
  State<CameraListPage> createState() => _CameraListPageState();
}

class _CameraListPageState extends State<CameraListPage> {
  int num = 0;

  @override
  void initState() {
    super.initState();
    ApiService.getNumCam().then((n) => setState(() => num = n));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Camera")),
      body: ListView.builder(
        itemCount: num,
        itemBuilder: (_, i) => ListTile(
          title: Text("Camera $i"),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => CameraViewPage(camId: i))),
        ),
      ),
    );
  }
}
