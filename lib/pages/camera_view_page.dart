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
//   late VideoPlayerController _controller;
//   bool _initializing = true;
//   String _error = "";

//   static const testUrl =
//       "https://5c3c535dd67e.ngrok-free.app/nai-cam0/index.m3u8";

//   @override
//   void initState() {
//     super.initState();
//     _setupVideo();
//   }

//   Future<void> _setupVideo() async {
//     final uri = Uri.parse(testUrl);

//     // If you need auth headers, pass them here; example:
//     // final headers = {'Authorization': 'Bearer ${ApiService.token}'};
//     final headers = <String, String>{};

//     try {
//       _controller = VideoPlayerController.networkUrl(uri, httpHeaders: headers);

//       // initialize returns a Future — wait for it
//       await _controller.initialize();

//       // optional: loop
//       _controller.setLooping(true);

//       // start playback
//       await _controller.play();

//       if (mounted) {
//         setState(() {
//           _initializing = false;
//         });
//       }
//     } catch (e) {
//       // capture error and show message in UI
//       _error = e.toString();
//       if (mounted) {
//         setState(() {
//           _initializing = false;
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Widget _buildBody() {
//     if (_initializing) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_error.isNotEmpty) {
//       return Center(child: Text("Playback error: $_error"));
//     }

//     if (!_controller.value.isInitialized) {
//       return const Center(child: Text("Player failed to initialize"));
//     }

//     return AspectRatio(
//       aspectRatio: _controller.value.aspectRatio,
//       child: VideoPlayer(_controller),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Camera ${widget.camId}")),
//       body: _buildBody(),
//       floatingActionButton: _controller.value.isInitialized
//           ? FloatingActionButton(
//               onPressed: () {
//                 setState(() {
//                   _controller.value.isPlaying ? _controller.pause() : _controller.play();
//                 });
//               },
//               child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
//             )
//           : null,
//     );
//   }
// }
import 'package:child_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';

class CameraViewPage extends StatefulWidget {
  final String cameraName;
  final String streamUrl;

  const CameraViewPage({
    super.key,
    required this.cameraName,
    required this.streamUrl,
  });

  @override
  State<CameraViewPage> createState() => _CameraViewPageState();
}

class _CameraViewPageState extends State<CameraViewPage> {
  VideoPlayerController? _controller;
  bool _loading = true;
  bool _error = false;
  String o_url = "$ApiService.baseUrl/cam/overlay/";
  @override
  void initState() {
    super.initState();

    _initPlayer();
  }

  Future<void> _initPlayer() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      _controller?.dispose();

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.streamUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      // await _controller!.initialize();
      // await _controller!.play();

      setState(() => _loading = false);
    } catch (e) {
      debugPrint("Camera error: $e");
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cameraName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initPlayer, // 🔁 reconnect stream
          ),
        ],
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _error
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("❌ Camera stream error"),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _initPlayer,
                    child: const Text("Retry"),
                  ),
                ],
              )
            : AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: MJPEGStreamScreen(
                  streamUrl: widget.streamUrl,
                  fit: BoxFit.cover,
                  showLiveIcon: false,
                ),
                //VideoPlayer(_controller!),
              ),
      ),
      floatingActionButton: !_loading && !_error
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying
                      ? _controller!.pause()
                      : _controller!.play();
                });
              },
              child: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
    );
  }
}
