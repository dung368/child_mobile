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
  String _password = "";
  final Set<String> _deleting = {}; // camera_id strings currently being deleted

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
      _password = data['password'] ?? "";
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
    final camId = cam['camera_id']?.toString() ?? '';
    if (_deleting.contains(camId)) return; // ignore while deleting
    try {
      await ApiService.setDriverCam(camId, val);
      setState(() {
        cam["is_driver"] = val;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> cam, int index) async {
    final camId = cam['camera_id']?.toString() ?? index.toString();
    final name = (cam['name'] as String?) ?? 'Camera';

    final should = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete camera'),
        content: Text('Delete "$name"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (should == true) {
      await _deleteCamera(camId, index);
    }
  }

  Future<void> _deleteCamera(String cameraId, int index) async {
    setState(() {
      _deleting.add(cameraId);
    });

    try {
      await ApiService.deleteCamera(cameraId);
      if (mounted) {
        setState(() {
          // remove by index if still valid, otherwise remove by camera_id
          if (index >= 0 &&
              index < _cameras.length &&
              _cameras[index]['camera_id']?.toString() == cameraId) {
            _cameras.removeAt(index);
          } else {
            _cameras.removeWhere((c) => c['camera_id']?.toString() == cameraId);
          }
          _deleting.remove(cameraId);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Camera deleted')));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _deleting.remove(cameraId);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete camera: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading){
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cameras"),
        actions: [
          IconButton(onPressed: _fetchCameras, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _cameras.isEmpty
          ? RefreshIndicator(
              onRefresh: _fetchCameras,
              child: ListView(
                children: const [
                  SizedBox(height: 24),
                  Center(child: Text("No cameras")),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchCameras,
              child: ListView.separated(
                itemCount: _cameras.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final cam = _cameras[index];
                  final name = (cam['name'] as String?) ?? 'Camera $index';
                  final url = (cam['url'] ?? cam['stream_url'] ?? '')
                      .toString();
                  final isDriver = cam["is_driver"] == true;
                  final camId =
                      cam['camera_id']?.toString() ?? index.toString();
                  final isDeleting = _deleting.contains(camId);

                  return ListTile(
                    leading: Icon(
                      isDriver ? Icons.drive_eta : Icons.videocam,
                      color: isDriver ? Colors.orange : null,
                    ),
                    title: Text(name),
                    subtitle: Text(
                      url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // driver switch (disabled while deleting)
                        IgnorePointer(
                          ignoring: isDeleting,
                          child: Opacity(
                            opacity: isDeleting ? 0.5 : 1.0,
                            child: Switch(
                              value: isDriver,
                              onChanged: (v) => _toggleDriver(cam, v),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // delete button or progress indicator
                        isDeleting
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _confirmDelete(cam, index),
                                tooltip: 'Delete camera',
                              ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return CameraViewPage(
                              cameraName: name,
                              streamUrl: url,
                              cameraId: cam['camera_id'],
                              camIndex: index,
                              username: _username,
                              password: _password
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
