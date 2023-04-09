import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('My App'),
        ),
        body: Center(
          child: ElevatedButton(
            child: const Text('Play Video'),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const VideoPlayerScreen(
              //       videoUrl:
              //           'https://storage.googleapis.com/kini_static/exercise/21597cb0/3da0/4b35/90b6/4b7076bb77fe/138c5ab2-bf72-4cfe-ab6d-f73b85eff8ab.mp4',
              //       audioUrl:
              //           'https://storage.googleapis.com/kini_static/exercise/78debd09/3138/4abd/9536/60a5384689f3/92f795ac-ed8f-41be-8293-67a231257747.mp3',
              //     ),
              //   ),
              // );
            },
          ),
        ),
      ),
    );
  }
}
