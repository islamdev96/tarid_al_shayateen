// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Widget createYoutubeEmbed({required String channelId}) {
  final String viewId = 'youtube-live-$channelId';

  // ignore: undefined_prefixed_name
  ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
    final html.IFrameElement iframe = html.IFrameElement()
      ..src = 'https://www.youtube.com/embed/live_stream?channel=$channelId&autoplay=1&mute=0'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
      ..allowFullscreen = true;
    return iframe;
  });

  return HtmlElementView(viewType: viewId);
}
