import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_theme.dart';
import '../models/dhikr.dart';

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

  @override
  void initState() {
    super.initState();
    _azkar = Dhikr.getByCategory(widget.category);
    _pageController = PageController();
    _remainingCounts = _azkar.map((d) => d.count).toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
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
        
        _goToNextDhikr();
      }
    }
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Center(
          child: Column(
            children: [
              Icon(Icons.stars_rounded, color: AppTheme.gold, size: 56),
              SizedBox(height: 12),
              Text(
                'تقبل الله طاعتكم',
                style: TextStyle(color: AppTheme.gold, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        content: const Text(
          'لقد تممت قراءة أذكار التحصين بنجاح. حفظك الله ورعاك.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 15, height: 1.5),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _resetSession();
                  },
                  child: const Text('إعادة قراءة'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pop(context); // Go back to Azkar category screen
                  },
                  child: const Text('رجوع'),
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
    if (_azkar.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text('لا توجد أذكار مضافة حالياً.', style: TextStyle(color: AppTheme.textPrimary)),
        ),
      );
    }

    final currentDhikr = _azkar[_currentIndex];
    final totalCount = currentDhikr.count;
    final remaining = _remainingCounts[_currentIndex];
    final completedPercent = totalCount > 0 ? (totalCount - remaining) / totalCount : 0.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar with progress indicator
              _buildTopBar(),
              
              // Dhikr PageView list
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: _azkar.length,
                  itemBuilder: (context, index) {
                    return _buildDhikrCard(_azkar[index], index);
                  },
                ),
              ),

              // Interactive Tasbeeh Circular Counter
              _buildCounterSection(remaining, totalCount, completedPercent),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final progressVal = (_currentIndex + 1) / _azkar.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.gold),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                Dhikr.getCategoryNameAr(widget.category),
                style: const TextStyle(color: AppTheme.gold, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${_currentIndex + 1} / ${_azkar.length}',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 14, fontWeight: FontWeight.bold),
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
                backgroundColor: AppTheme.cardBorder.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
                minHeight: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDhikrCard(Dhikr dhikr, int index) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.glassCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text of Dhikr
            Center(
              child: Text(
                dhikr.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  height: 1.8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            
            // Virtue / Reward
            if (dhikr.virtue.isNotEmpty) ...[
              const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppTheme.gold, size: 18),
                  SizedBox(width: 6),
                  Text('فضل الذكر', style: TextStyle(color: AppTheme.gold, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                dhikr.virtue,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 16),
            ],

            // Source / Reference
            const Row(
              children: [
                Icon(Icons.history_edu_rounded, color: AppTheme.textMuted, size: 18),
                SizedBox(width: 6),
                Text('تخريج الحديث والإسناد', style: TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              dhikr.source,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, height: 1.5, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterSection(int remaining, int totalCount, double completedPercent) {
    return GestureDetector(
      onTap: _onTapCircle,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.gold.withValues(alpha: remaining > 0 ? 0.15 : 0.05),
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
                backgroundColor: AppTheme.cardBorder,
                valueColor: AlwaysStoppedAnimation<Color>(
                  remaining > 0 ? AppTheme.gold : AppTheme.successGreen,
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
                    style: const TextStyle(
                      fontSize: 36,
                      color: AppTheme.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'تكرار',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                ] else ...[
                  const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 48),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
