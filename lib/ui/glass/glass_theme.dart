import 'package:flutter/material.dart';

class GlassTokens {
  // درجات الشفافية — قيم iOS ultraThinMaterial الدقيقة
  static const double cardOpacity = 0.12;   // أخف من الأول عشان إحساس frosted ناعم
  static const double barOpacity = 0.16;
  static const double sheetOpacity = 0.14;

  // البلور — iOS بيستخدم بلور أقوى بكتير
  static const double softBlur = 30;
  static const double strongBlur = 50;

  // الحواف الدائرية — iOS continuous corner radius
  static const double radius = 22;
  static const double radiusLarge = 30;

  // التينت: رمادي-أبيض خفيف زي ultraThinMaterial (مش أبيض صريح)
  static const Color lightTint = Color(0xFFEBEBF5);
  static const Color darkTint = Color(0xFF1C1C1E);

  // شفافية الحدود — أبيض شفاف خفيف جدًا زي iOS
  static const double borderOpacity = 0.18;
}
