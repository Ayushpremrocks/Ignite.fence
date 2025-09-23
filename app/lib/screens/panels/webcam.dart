// ================= screens/panels/webcam.dart =================
import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

class LiveFeedPage extends StatefulWidget {
  const LiveFeedPage({super.key});

  @override
  State<LiveFeedPage> createState() => _LiveFeedPageState();
}

class _LiveFeedPageState extends State<LiveFeedPage> {
  // Replace with your IP webcam stream URL
  final String feedUrl = 'http://10.46.121.80:8080/video';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Live Feed'),
        backgroundColor: const Color(0xFF1B263B),
      ),
      body: Center(
        child: Mjpeg(
          stream: feedUrl,
          isLive: true,
          error: (context, error, stack) {
            return const Center(
              child: Text(
                'Error loading feed',
                style: TextStyle(color: Colors.red),
              ),
            );
          },
        ),
      ),
    );
  }
}
