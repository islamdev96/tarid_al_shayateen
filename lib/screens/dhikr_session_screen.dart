import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import '../app_theme.dart';
import '../models/dhikr.dart';
import '../widgets/glass_card.dart';
import '../widgets/glassy_background.dart';

class DhikrSessionScreen extends StatefulWidget {
  final DhikrCategory category;

  const DhikrSessionScreen({super.key, required this.category});

  @override
  State<DhikrSessionScreen> createState() => _DhikrSessionScreenState();
}

class _DhikrSessionScreenState extends State<DhikrSessionScreen> {
  late List<Dhikr> _azkar;
  late PageController _pageController;
  int _currentIndex = 0;
  
  // Track remaining counts for each dhikr in the session
  late List<int> _remainingCounts;
  
  // Player for transition sound effect
  final AudioPlayer _soundPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _azkar = Dhikr.getByCategory(widget.category);
    _pageController = PageController();
    _remainingCounts = _azkar.map((d) => d.count).toList();
    _loadSoundEffect();
  }

  Future<void> _loadSoundEffect() async {
    try {
      await _soundPlayer.setAsset('assets/transition.mp3');
    } catch (e) {
      debugPrint('Error loading transition sound: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _soundPlayer.dispose();
    super.dispose();
  }

  void _onTapCircle() {
    if (_remainingCounts[_currentIndex] > 0) {
      setState(() {
        _remainingCounts[_currentIndex]--;
      });

      // Subtle haptic vibration for feedback
      HapticFeedback.lightImpact();

      if (_remainingCounts[_currentIndex] == 0) {
        // Stronger vibration on completion of current dhikr
        HapticFeedback.mediumImpact();
        
        // Play transition chime sound only for the last dhikr (otherwise page transition will play it)
        if (_currentIndex == _azkar.length - 1) {
          _playTransitionSound();
        }
        
        _goToNextDhikr();
      }
    }
  }

  Future<void> _playTransitionSound() async {
    try {
      await _soundPlayer.seek(Duration.zero);
      _soundPlayer.play();
    } catch (_) {}
  }

  void _goToNextDhikr() {
    if (_currentIndex < _azkar.length - 1) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    } else {
      // Completed all Azkar
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _showCompletionDialog();
        }
      });
    }
  }

  void _resetSession() {
    setState(() {
      _currentIndex = 0;
      _remainingCounts = _azkar.map((d) => d.count).toList();
    });
    _pageController.jumpToPage(0);
  }

  void _showCompletionDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Center(
          child: Column(
            children: [
              Icon(CupertinoIcons.star_fill, color: theme.colorScheme.primary, size: 56),
              const SizedBox(height: 12),
              Text(
                'تقبل الله طاعتكم',
                style: TextStyle(color: theme.colorScheme.primary, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              ),
            ],
          ),
        ),
        content: Text(
          'لقد تممت قراءة أذكار حصن المسلم بنجاح. حفظك الله ورعاك.',
          textAlign: TextAlign.center,
          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.8), fontSize: 15, height: 1.5, fontFamily: 'Cairo'),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _resetSession();
                  },
                  child: const Text('إعادة قراءة', style: TextStyle(fontFamily: 'Cairo')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pop(context); // Go back to Azkar category screen
                  },
                  child: const Text('رجوع', style: TextStyle(fontFamily: 'Cairo')),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_azkar.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text('لا توجد أذكار مضافة حالياً.', style: TextStyle(color: theme.colorScheme.onSurface, fontFamily: 'Cairo')),
        ),
      );
    }

    final currentDhikr = _azkar[_currentIndex];
    final totalCount = currentDhikr.count;
    final remaining = _remainingCounts[_currentIndex];
    final completedPercent = totalCount > 0 ? (totalCount - remaining) / totalCount : 0.0;

    return Scaffold(
      body: GlassyBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar with progress indicator
              _buildTopBar(theme),
              
              // Dhikr PageView list
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                    _playTransitionSound();
                  },
                  itemCount: _azkar.length,
                  itemBuilder: (context, index) {
                    return _buildDhikrCard(_azkar[index], index, theme);
                  },
                ),
              ),

              // Interactive Tasbeeh Circular Counter
              _buildCounterSection(remaining, totalCount, completedPercent, theme),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    final progressVal = (_currentIndex + 1) / _azkar.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_forward_ios_rounded, color: theme.colorScheme.primary, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                Dhikr.getCategoryNameAr(widget.category),
                style: TextStyle(color: theme.colorScheme.primary, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              ),
              Text(
                '${_currentIndex + 1} / ${_azkar.length}',
                style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progressVal,
                backgroundColor: theme.brightness == Brightness.dark ? AppTheme.cardBorder : AppTheme.lightCardBorder,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                minHeight: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDhikrCard(Dhikr dhikr, int index, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: _onTapCircle,
      behavior: HitTestBehavior.opaque,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text of Dhikr
              Center(
                child: Text(
                  dhikr.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 20,
                    height: 1.8,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: dhikr.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم نسخ الذكر إلى الحافظة', style: TextStyle(fontFamily: 'Cairo')),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: Icon(CupertinoIcons.doc_on_doc, color: theme.colorScheme.primary, size: 18),
                    label: Text(
                      'نسخ الذكر',
                      style: TextStyle(color: theme.colorScheme.primary, fontFamily: 'Cairo', fontSize: 13),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Share.share(
                        '${dhikr.text}\n\nفضل الذكر: ${dhikr.virtue}\nالمصدر: ${dhikr.source}\n\nتمت المشاركة من تطبيق سَكينة',
                        subject: 'أذكار اليوم',
                      );
                    },
                    icon: Icon(CupertinoIcons.share, color: theme.colorScheme.primary, size: 18),
                    label: Text(
                      'مشاركة',
                      style: TextStyle(color: theme.colorScheme.primary, fontFamily: 'Cairo', fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 12),
              
              // Virtue / Reward
              if (dhikr.virtue.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(CupertinoIcons.info, color: theme.colorScheme.primary, size: 18),
                    const SizedBox(width: 6),
                    Text('فضل الذكر', style: TextStyle(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  dhikr.virtue,
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 13, height: 1.5, fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 16),
              ],

              // Source / Reference
              Row(
                children: [
                  Icon(CupertinoIcons.book, color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted, size: 18),
                  const SizedBox(width: 6),
                  Text('تخريج الحديث والإسناد', style: TextStyle(color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                dhikr.source,
                style: TextStyle(color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted, fontSize: 12, height: 1.5, fontStyle: FontStyle.italic, fontFamily: 'Cairo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterSection(int remaining, int totalCount, double completedPercent, ThemeData theme) {
    return GestureDetector(
      onTap: _onTapCircle,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: remaining > 0 ? 0.15 : 0.05),
              blurRadius: 24,
              spreadRadius: 2,
            )
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular progress indicator track
            SizedBox(
              width: 130,
              height: 130,
              child: CircularProgressIndicator(
                value: completedPercent,
                strokeWidth: 8,
                backgroundColor: theme.brightness == Brightness.dark ? AppTheme.cardBorder : AppTheme.lightCardBorder,
                valueColor: AlwaysStoppedAnimation<Color>(
                  remaining > 0 ? theme.colorScheme.primary : AppTheme.successGreen,
                ),
              ),
            ),
            
            // Inside text
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (remaining > 0) ...[
                  Text(
                    remaining.toString(),
                    style: TextStyle(
                      fontSize: 36,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'تكرار',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ] else ...[
                  const Icon(CupertinoIcons.checkmark_circle_fill, color: AppTheme.successGreen, size: 48),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
