import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
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
  late VideoPlayerController _videoController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
    _initAudioPlayer();
  }

  Future<void> _initVideoPlayer() async {
    _videoController = VideoPlayerController.network(
      widget.videoUrl,
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    );
    await _videoController.initialize();
    _videoController.setVolume(0);

    // Needed so that play/pause button and custom progress bar are updated
    _videoController.addListener(() {
      if (!mounted) {
        return;
      }
      setState(() {});
    });

    // Pause audio player when video is buffering
    _videoController.addListener(() {
      if (_videoController.value.isBuffering) {
        _audioPlayer.pause();
      } else if (_videoController.value.isPlaying) {
        _audioPlayer.play();
      }
    });

    // Stop audio once video is finished
    _videoController.addListener(() {
      if (_videoController.value.position == _videoController.value.duration) {
        _audioPlayer.setLoopMode(LoopMode.off);
        _audioPlayer.stop();
      } else {
        _audioPlayer.setLoopMode(LoopMode.one);
      }
    });

    // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
    setState(() {});
  }

  Future<void> _initAudioPlayer() async {
    await _audioPlayer.setUrl(widget.audioUrl);
    await _audioPlayer.setVolume(1);
    _audioPlayer.setLoopMode(LoopMode.one);
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
            child: _videoController.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: VideoPlayer(_videoController),
                  )
                : Container(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            // // Default progress bar
            // child: VideoProgressIndicator(
            //   _videoController,
            //   allowScrubbing: true,
            // ),
            // Custom progress bar
            child: StreamBuilder<DurationState>(
              stream: _videoController.position.asStream().map(
                (progress) {
                  return DurationState(
                    progress: progress ?? Duration.zero,
                    buffered: _videoController.value.buffered.last.end,
                    total: _videoController.value.duration,
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
                    _videoController.seekTo(duration);
                  },
                );
              },
            ),
          ), // Video ProgressBar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<DurationState>(
              stream: _audioPlayer.positionStream.map(
                (progress) => DurationState(
                  progress: progress,
                  buffered: _audioPlayer.bufferedPosition,
                  total: _audioPlayer.duration ?? Duration.zero,
                ),
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
                    _audioPlayer.seek(duration);
                  },
                );
              },
            ), // Audio ProgressBar
          ),
          const Spacer(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!_videoController.value.isInitialized) return;
          setState(() {
            if (_videoController.value.isPlaying) {
              _videoController.pause();
              _audioPlayer.pause();
            } else {
              _videoController.play();
              _audioPlayer.play();
            }
          });
        },
        child: Icon(
          _videoController.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _videoController.dispose();
    _audioPlayer.dispose();
  }
}

class DurationState {
  const DurationState(
      {required this.progress, required this.buffered, required this.total});
  final Duration progress;
  final Duration buffered;
  final Duration total;
}
