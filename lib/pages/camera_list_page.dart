// lib/pages/camera_list_page.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'camera_view_page.dart';

class CameraListPage extends StatefulWidget {
  const CameraListPage({super.key});
  @override
  State<CameraListPage> createState() => _CameraListPageState();
}

class _CameraListPageState extends State<CameraListPage> {
  List<Map<String, dynamic>> _cameras = [];
  bool _loading = true;
  String? _error;
  String _username = "";

  @override
  void initState() {
    super.initState();
    _fetchCameras();
  }

  Future<void> _fetchCameras() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await ApiService.getCurrent();
      final camsRaw = data['cameras'];
      _username = data['username'] ?? "";
      if (camsRaw is List) {
        _cameras = camsRaw.map<Map<String, dynamic>>((e) {
          if (e is Map) return Map<String, dynamic>.from(e as Map);
          return <String, dynamic>{};
        }).toList();
      } else {
        _cameras = [];
      }
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _toggleDriver(Map<String, dynamic> cam, bool val) async {
    try {
      await ApiService.setDriverCam(cam["camera_id"], val);
      setState(() {
        cam["is_driver"] = val;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text("Cameras"), actions: [
        IconButton(onPressed: _fetchCameras, icon: const Icon(Icons.refresh))
      ]),
      body: _cameras.isEmpty
          ? RefreshIndicator(onRefresh: _fetchCameras, child: ListView(children: const [
              SizedBox(height: 24),
              Center(child: Text("No cameras")),
            ]))
          : RefreshIndicator(
              onRefresh: _fetchCameras,
              child: ListView.separated(
                itemCount: _cameras.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final cam = _cameras[index];
                  final name = (cam['name'] as String?) ?? 'Camera $index';
                  final url = (cam['url'] ?? cam['stream_url'] ?? '').toString();
                  final isDriver = cam["is_driver"] == true;
                  return ListTile(
                    leading: Icon(isDriver ? Icons.drive_eta : Icons.videocam, color: isDriver ? Colors.orange : null),
                    title: Text(name),
                    subtitle: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Switch(value: isDriver, onChanged: (v) => _toggleDriver(cam, v)),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return CameraViewPage(
                          cameraName: name,
                          streamUrl: url,
                          cameraId: cam['camera_id'],
                          camIndex: index,
                          username: _username,
                        );
                      }));
                    },
                  );
                },
              ),
            ),
    );
  }
}
