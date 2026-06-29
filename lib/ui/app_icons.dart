import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// مصدر واحد لكل أيقونات التطبيق — ممنوع استخدام Icons.* أو CupertinoIcons.* مباشرة في أي شاشة.
class AppIcons {
  // التنقّل
  static const IconData home = CupertinoIcons.house_fill;
  static const IconData quran = CupertinoIcons.book_fill;
  static const IconData prayerTimes = CupertinoIcons.clock_fill;
  static const IconData azkar = CupertinoIcons.shield_fill;
  static const IconData settings = CupertinoIcons.settings_solid;

  // إجراءات شائعة
  static const IconData play = CupertinoIcons.play_fill;
  static const IconData pause = CupertinoIcons.pause_fill;
  static const IconData next = CupertinoIcons.forward_fill;
  static const IconData prev = CupertinoIcons.backward_fill;
  static const IconData share = CupertinoIcons.share;
  static const IconData search = CupertinoIcons.search;
  static const IconData back = Icons.arrow_forward_ios_rounded;
  static const IconData close = CupertinoIcons.xmark;
  static const IconData add = CupertinoIcons.add;
  static const IconData more = CupertinoIcons.ellipsis;
  static const IconData check = CupertinoIcons.checkmark_alt;
  static const IconData bookmark = CupertinoIcons.bookmark_fill;
  static const IconData moon = CupertinoIcons.moon_fill;
  static const IconData sun = CupertinoIcons.sun_max_fill;

  static const IconData mic = CupertinoIcons.mic_fill;
}
