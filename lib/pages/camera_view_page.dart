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
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    print("ok");
    controller = VideoPlayerController.network(
      ApiService.camUrl(widget.camId),
      httpHeaders: ApiService.authHeaders(),
    );
    print(ApiService.camUrl(widget.camId));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Camera ${widget.camId}")),
      body: Center(
        child: controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
