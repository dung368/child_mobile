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

  Future<void> _confirmAndDelete(String cameraId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete camera?'),
        content: const Text(
          'This will permanently remove the camera. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await ApiService.deleteCamera(cameraId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camera deleted')));
      await _fetchCameras();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Error: $_error"),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchCameras,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_cameras.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchCameras,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 24),
            Icon(Icons.videocam_off, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Center(child: Text("No cameras found for this account")),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCameras,
      child: ListView.separated(
        itemCount: _cameras.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final cam = _cameras[index];
          final name = (cam['name'] as String?) ?? 'Camera $index';
          final url = (cam['url'] ?? cam['stream_url'] ?? cam['rtsp'] ?? '')
              .toString();
          final cameraId = (cam['camera_id'] as String?) ?? '';

          return ListTile(
            leading: const Icon(Icons.videocam),
            title: Text(name),
            subtitle: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'play') {
                  if (url.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Camera has no stream URL")),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CameraViewPage(cameraName: name, streamUrl: url),
                    ),
                  );
                } else if (v == 'delete') {
                  if (cameraId.isEmpty) {
                    // fallback: optionally ask server to delete by index via /cam/index/{index}
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cannot delete: missing camera_id'),
                      ),
                    );
                    return;
                  }
                  await _confirmAndDelete(cameraId);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'play',
                  child: ListTile(
                    leading: Icon(Icons.play_arrow),
                    title: Text('Play'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                  ),
                ),
              ],
            ),
            onTap: () {
              if (url.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Camera has no stream URL")),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CameraViewPage(cameraName: name, streamUrl: url),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cameras"),
        actions: [
          IconButton(
            onPressed: _fetchCameras,
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _cameras.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                final cam = _cameras.first;
                final name = (cam['name'] as String?) ?? 'Camera 0';
                final url =
                    (cam['url'] ?? cam['stream_url'] ?? cam['rtsp'] ?? '')
                        .toString();
                if (url.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("First camera has no stream URL"),
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CameraViewPage(cameraName: name, streamUrl: url),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text("Play first"),
            )
          : null,
    );
  }
}
