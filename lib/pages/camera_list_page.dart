// import 'package:flutter/material.dart';
// import '../services/api_service.dart';
// import 'camera_view_page.dart';

// class CameraListPage extends StatefulWidget {
//   const CameraListPage({super.key});
//   @override
//   State<CameraListPage> createState() => _CameraListPageState();
// }

// class _CameraListPageState extends State<CameraListPage> {
//   int num = 0;

//   @override
//   void initState() {
//     super.initState();
//     ApiService.getNumCam().then((n) => setState(() => num = n));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Camera")),
//       body: ListView.builder(
//         itemCount: num,
//         itemBuilder: (_, i) => ListTile(
//           title: Text("Camera $i"),
//           onTap: () => Navigator.push(context,
//               MaterialPageRoute(builder: (_) => CameraViewPage(camId: i))),
//         ),
//       ),
//     );
//   }
// }
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
        // Normalize each item to a Map<String, dynamic>
        _cameras = camsRaw.map<Map<String, dynamic>>((e) {
          if (e is Map) {
            // ensure proper typing
            return Map<String, dynamic>.from(e as Map);
          }
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

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

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
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(Icons.videocam_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text("No cameras found for this account"),
                  const SizedBox(height: 8),
                  const Text("Tap the refresh button to re-check."),
                ],
              ),
            ),
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
          // support both "url" and "stream_url" from different server versions
          final url = (cam['url'] ?? cam['stream_url'] ?? cam['rtsp'] ?? '').toString();

          return ListTile(
            leading: const Icon(Icons.videocam),
            title: Text(name),
            subtitle: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.chevron_right),
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
                  builder: (_) => CameraViewPage(
                    cameraName: name,
                    streamUrl: url,
                  ),
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
                // quick helper: view first camera (camera 0)
                final cam = _cameras.first;
                final name = (cam['name'] as String?) ?? 'Camera 0';
                final url = (cam['url'] ?? cam['stream_url'] ?? cam['rtsp'] ?? '').toString();
                if (url.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("First camera has no stream URL")),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CameraViewPage(cameraName: name, streamUrl: url),
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
