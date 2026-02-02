// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import '../services/api_service.dart';

// class CameraViewPage extends StatefulWidget {
//   final int camId;
//   const CameraViewPage({required this.camId, super.key});
//   @override
//   State<CameraViewPage> createState() => _CameraViewPageState();
// }

// class _CameraViewPageState extends State<CameraViewPage> {
//   late VideoPlayerController controller;

//   @override
//   void initState() {
//     super.initState();
//     print("ok");
//     controller = VideoPlayerController.networkUrl(
//       Uri.parse("https://s3-streaming.baotintuc.vn/baotintuc/Video/2026_02_01/cbewjdcv_kxstd.qpdixcijr.kc_tEx_RBH_80273/")
//       // httpHeaders: ApiService.authHeaders(),
//     );
//     print(ApiService.camUrl(widget.camId));
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Camera ${widget.camId}")),
//       body: Center(
//         child: controller.value.isInitialized
//             ? AspectRatio(
//                 aspectRatio: controller.value.aspectRatio,
//                 child: VideoPlayer(controller),
//               )
//             : const CircularProgressIndicator(),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/api_service.dart';

class CameraViewPage extends StatefulWidget {
  final int camId;
  const CameraViewPage({required this.camId, super.key});
  @override
  State<CameraViewPage> createState() => _CameraViewPageState();
}

class _CameraViewPageState extends State<CameraViewPage> {
  late VideoPlayerController _controller;
  bool _initializing = true;
  String _error = "";

  static const testUrl =
      "https://39f19e59e7c1.ngrok-free.app/nai-cam0/index.m3u8";

  @override
  void initState() {
    super.initState();
    _setupVideo();
  }

  Future<void> _setupVideo() async {
    final uri = Uri.parse(testUrl);

    // If you need auth headers, pass them here; example:
    // final headers = {'Authorization': 'Bearer ${ApiService.token}'};
    final headers = <String, String>{};

    try {
      _controller = VideoPlayerController.networkUrl(uri, httpHeaders: headers);

      // initialize returns a Future — wait for it
      await _controller.initialize();

      // optional: loop
      _controller.setLooping(true);

      // start playback
      await _controller.play();

      if (mounted) {
        setState(() {
          _initializing = false;
        });
      }
    } catch (e) {
      // capture error and show message in UI
      _error = e.toString();
      if (mounted) {
        setState(() {
          _initializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBody() {
    if (_initializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(child: Text("Playback error: $_error"));
    }

    if (!_controller.value.isInitialized) {
      return const Center(child: Text("Player failed to initialize"));
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Camera ${widget.camId}")),
      body: _buildBody(),
      floatingActionButton: _controller.value.isInitialized
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying ? _controller.pause() : _controller.play();
                });
              },
              child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
            )
          : null,
    );
  }
}
