import 'package:flutter/material.dart';
import '../models/quran_verse.dart';

class QuranVerseWidget extends StatelessWidget {
  final QuranVerse verse;
  final bool isSelected;
  final bool isPlaying;
  final double fontSizeMultiplier;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const QuranVerseWidget({
    super.key,
    required this.verse,
    required this.isSelected,
    this.isPlaying = false,
    this.fontSizeMultiplier = 1.0,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // The text spans for words (future-proofing for word-by-word highlights)
    final spans = verse.words.map((word) {
      return TextSpan(
        text: '${word.textUthmani} ',
        style: TextStyle(
          color: isPlaying ? theme.colorScheme.primary : (isDark ? Colors.white : Colors.black87),
        ),
      );
    }).toList();

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : (isPlaying ? theme.colorScheme.primary.withValues(alpha: 0.05) : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 1)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RichText(
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Amiri', // Or any good Quranic font available
                  fontSize: 24 * fontSizeMultiplier,
                  height: 1.8,
                ),
                children: spans,
              ),
            ),
            const SizedBox(height: 8),
            // Verse End Symbol with Number
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                ),
                child: Text(
                  _convertNumberToArabic(verse.verseKey.split(':').last),
                  style: TextStyle(
                    fontSize: 12 * fontSizeMultiplier,
                    fontFamily: 'Cairo',
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _convertNumberToArabic(String number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < english.length; i++) {
      number = number.replaceAll(english[i], arabic[i]);
    }
    return number;
  }
}
