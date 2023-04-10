import 'dart:developer';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MultiSourcePlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String audioUrl;

  const MultiSourcePlayerScreen(
      {Key? key, required this.videoUrl, required this.audioUrl})
      : super(key: key);

  @override
  State<MultiSourcePlayerScreen> createState() =>
      _MultiSourcePlayerScreenState();
}

class _MultiSourcePlayerScreenState extends State<MultiSourcePlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      widget.videoUrl,
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: false,
      ),
    )..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});

        _controller.setVolume(0);
        _controller.addListener(() {
          // Needed so that play/pause button and custom progress bar are updated
          if (!mounted) {
            return;
          }
          setState(() {});
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MultiSource Player'),
      ),
      body: Column(
        children: [
          const Spacer(),
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : Container(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            // // Default progress bar
            // child: VideoProgressIndicator(
            //   _controller,
            //   allowScrubbing: true,
            // ),
            // Custom progress bar
            child: StreamBuilder<DurationState>(
              stream: _controller.position.asStream().map(
                (progress) {
                  return DurationState(
                    progress: progress ?? Duration.zero,
                    buffered: _controller.value.buffered.last.end,
                    total: _controller.value.duration,
                  );
                },
              ),
              builder: (context, snapshot) {
                final durationState = snapshot.data;
                final progress = durationState?.progress ?? Duration.zero;
                final buffered = durationState?.buffered ?? Duration.zero;
                final total = durationState?.total ?? Duration.zero;
                return ProgressBar(
                  progress: progress,
                  buffered: buffered,
                  total: total,
                  onSeek: (duration) {
                    _controller.seekTo(duration);
                  },
                );
              },
            ),
          ), // Video ProgressBar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ProgressBar(
              progress: const Duration(milliseconds: 1000),
              buffered: const Duration(milliseconds: 2000),
              total: const Duration(milliseconds: 5000),
              onSeek: (duration) {
                log('User selected a new time: $duration');
              },
            ), // Audio ProgressBar
          ),
          const Spacer(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class DurationState {
  const DurationState(
      {required this.progress, required this.buffered, required this.total});
  final Duration progress;
  final Duration buffered;
  final Duration total;
}
