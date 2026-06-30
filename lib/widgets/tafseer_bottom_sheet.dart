import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';
import '../models/quran_verse.dart';
import '../services/quran_api_service.dart';
import '../app_theme.dart';

class TafseerBottomSheet extends StatefulWidget {
  final QuranVerse verse;
  final VoidCallback onPlayAudio;

  const TafseerBottomSheet({
    super.key,
    required this.verse,
    required this.onPlayAudio,
  });

  static void show(BuildContext context, QuranVerse verse, VoidCallback onPlayAudio) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TafseerBottomSheet(verse: verse, onPlayAudio: onPlayAudio),
    );
  }

  @override
  State<TafseerBottomSheet> createState() => _TafseerBottomSheetState();
}

class _TafseerBottomSheetState extends State<TafseerBottomSheet> {
  final QuranApiService _apiService = QuranApiService();
  TafseerData? _tafseerData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTafseer();
  }

  Future<void> _fetchTafseer() async {
    try {
      final data = await _apiService.getTafseer(widget.verse.verseKey);
      if (mounted) {
        setState(() {
          _tafseerData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'حدث خطأ أثناء جلب التفسير. يرجى التحقق من اتصالك بالإنترنت.';
          _isLoading = false;
        });
      }
    }
  }

  void _shareVerse() {
    final textToShare = '﴿ ${widget.verse.textUthmani} ﴾\n[سورة/آية: ${widget.verse.verseKey}]\n\nتمت المشاركة من تطبيق سَكينة';
    Share.share(textToShare);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.deepBackground : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white30 : Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Action Buttons Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context,
                  icon: CupertinoIcons.play_circle_fill,
                  label: 'استماع',
                  color: theme.colorScheme.primary,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onPlayAudio();
                  },
                ),
                _buildActionButton(
                  context,
                  icon: CupertinoIcons.share,
                  label: 'مشاركة',
                  color: Colors.blue,
                  onTap: _shareVerse,
                ),
                _buildActionButton(
                  context,
                  icon: CupertinoIcons.doc_on_clipboard,
                  label: 'نسخ',
                  color: Colors.orange,
                  onTap: () {
                     Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 24),

          // Tafseer Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                Text(
                  'الآية ${widget.verse.verseKey}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.verse.textUthmani,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 22,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 24),
                const Text(
                  'التفسير الميسر',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 12),
                if (_isLoading)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CupertinoActivityIndicator(radius: 16),
                  ))
                else if (_error != null)
                  Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppTheme.errorRed, fontFamily: 'Cairo'),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Text(
                    _tafseerData?.text ?? '',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                    textDirection: TextDirection.rtl,
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
