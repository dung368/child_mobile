// lib/pages/camera_view_page.dart
import 'package:flutter/material.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';
import '../services/api_service.dart';

class CameraViewPage extends StatefulWidget {
  final String cameraName;
  final String streamUrl; // raw HLS/RTSP/HLS url
  final String cameraId;
  final int camIndex;
  final String username;

  const CameraViewPage({
    super.key,
    required this.cameraName,
    required this.streamUrl,
    required this.cameraId,
    required this.camIndex,
    required this.username,
  });

  @override
  State<CameraViewPage> createState() => _CameraViewPageState();
}

class _CameraViewPageState extends State<CameraViewPage> {
  bool _useOverlay = true;
  int _reload = 0;

  String get overlayUrl {
    // server overlay endpoint e.g. http://192.168.1.52:8000/overlay?username=nai&cam_index=0
    final base = ApiService.baseUrl;
    return "$base/overlay?username=${Uri.encodeComponent(widget.username)}&cam_index=${widget.camIndex}&_=${_reload}";
  }

  @override
  Widget build(BuildContext context) {
    final displayUrl = _useOverlay ? overlayUrl : widget.streamUrl;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cameraName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _reload++),
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Toggle overlay/raw',
            onPressed: () => setState(() => _useOverlay = !_useOverlay),
          ),
        ],
      ),
      body: Center(
        child: MJPEGStreamScreen(
          streamUrl: displayUrl,
          showLiveIcon: !_useOverlay,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
