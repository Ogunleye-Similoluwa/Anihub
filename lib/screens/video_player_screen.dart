import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:anihub/services/consumet_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String episodeId;
  final String title;

  const VideoPlayerScreen({
    Key? key,
    required this.episodeId,
    required this.title,
  }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final ConsumetService _consumetService = ConsumetService();
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final streamingData = await _consumetService.getStreamingLinks(widget.episodeId);
      
      // Get the best quality URL (you might want to let users choose quality)
      final sources = streamingData['sources'] as List;
      final videoUrl = sources.firstWhere(
        (source) => source['quality'] == '1080p' || source['quality'] == '720p',
        orElse: () => sources.first,
      )['url'] as String;

      _videoPlayerController = VideoPlayerController.network(videoUrl);
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            ElevatedButton(
              onPressed: _initializePlayer,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_chewieController != null) {
      return Center(
        child: Chewie(controller: _chewieController!),
      );
    }

    return const Center(
      child: Text('Failed to load video'),
    );
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
} 