import 'package:flutter/material.dart';
import 'package:multi_source_player/screens/multi_source_player_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Play Video'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MultiSourcePlayerScreen(
                  videoUrl:
                      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
                  audioUrl:
                      'https://storage.googleapis.com/kini_static/exercise/78debd09/3138/4abd/9536/60a5384689f3/92f795ac-ed8f-41be-8293-67a231257747.mp3',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
