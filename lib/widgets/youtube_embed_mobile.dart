import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Widget createYoutubeEmbed({required String channelId}) {
  final url = 'https://www.youtube.com/channel/$channelId/live';
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.tv, size: 48, color: Colors.grey),
        const SizedBox(height: 12),
        const Text(
          'يرجى فتح البث في تطبيق يوتيوب',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('فتح في يوتيوب', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}
