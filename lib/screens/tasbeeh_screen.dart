import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/glassy_background.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  int _counter = 0;
  int _target = 33;
  int _totalDhikrToday = 0;
  int _selectedDhikrIndex = 0;
  
  final List<String> _defaultDhikrs = [
    'سُبْحَانَ اللَّهِ',
    'الْحَمْدُ لِلَّهِ',
    'لَا إِلَهَ إِلَّا اللَّهُ',
    'اللَّهُ أَكْبَرُ',
    'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
    'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
  ];

  final AudioPlayer _soundPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadState();
    _loadSound();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt('tasbeeh_counter') ?? 0;
      _target = prefs.getInt('tasbeeh_target') ?? 33;
      _totalDhikrToday = prefs.getInt('tasbeeh_total_today') ?? 0;
      _selectedDhikrIndex = prefs.getInt('tasbeeh_selected_index') ?? 0;
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbeeh_counter', _counter);
    await prefs.setInt('tasbeeh_target', _target);
    await prefs.setInt('tasbeeh_total_today', _totalDhikrToday);
    await prefs.setInt('tasbeeh_selected_index', _selectedDhikrIndex);
  }

  Future<void> _loadSound() async {
    try {
      await _soundPlayer.setAsset('assets/transition.mp3');
    } catch (e) {
      debugPrint('Error loading sound: $e');
    }
  }

  @override
  void dispose() {
    _soundPlayer.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      _totalDhikrToday++;
      
      // Haptic feedback on tap
      HapticFeedback.lightImpact();

      // Check if target reached
      if (_counter == _target) {
        HapticFeedback.mediumImpact();
        _playChimeSound();
        _showTargetReachedSnackBar();
      }
    });
    _saveState();
  }

  Future<void> _playChimeSound() async {
    try {
      await _soundPlayer.seek(Duration.zero);
      _soundPlayer.play();
    } catch (_) {}
  }

  void _showTargetReachedSnackBar() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'أتممت قراءة الذكر $_target مرة! تقبل الله منك.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
    _saveState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = _target > 0 ? (_counter / _target).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      body: GlassyBackground(
        child: SafeArea(
          child: Column(
            children: [
              // iOS-Style Top Nav Bar
              _buildTopBar(theme),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // Dhikr Selector Dropdown Card
                      _buildDhikrSelectorCard(theme, isDark),
                      const SizedBox(height: 24),

                      // Statistics Card
                      _buildStatsRow(theme, isDark),
                      const SizedBox(height: 36),

                      // Interactive Tasbeeh Tap Area
                      Expanded(
                        child: Center(
                          child: _buildCircularCounter(progress, theme, isDark),
                        ),
                      ),

                      // Reset and Target controls
                      _buildControlButtons(theme, isDark),
                      const SizedBox(height: 120), // Padding to avoid overlap with mini player
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_forward_ios_rounded, color: theme.colorScheme.primary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'المسبحة الإلكترونية',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          ),
          IconButton(
            icon: Icon(CupertinoIcons.refresh, color: theme.colorScheme.primary),
            onPressed: _resetCounter,
            tooltip: 'تصفير العداد',
          ),
        ],
      ),
    );
  }

  Widget _buildDhikrSelectorCard(ThemeData theme, bool isDark) {
    return GlassCard(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'الذكر الحالي',
            style: TextStyle(
              color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
              fontSize: 12,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedDhikrIndex,
              isExpanded: true,
              icon: Icon(CupertinoIcons.chevron_down, color: theme.colorScheme.primary, size: 16),
              dropdownColor: isDark ? const Color(0xFF0C1921) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              alignment: AlignmentDirectional.centerEnd,
              items: List.generate(_defaultDhikrs.length, (index) {
                return DropdownMenuItem(
                  value: index,
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    _defaultDhikrs[index],
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                );
              }),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedDhikrIndex = val;
                    _counter = 0; // reset active count on changing dhikr
                  });
                  _saveState();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                Text(
                  'المجموع اليومي',
                  style: TextStyle(
                    color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_totalDhikrToday',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                Text(
                  'الهدف المطلوب',
                  style: TextStyle(
                    color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_target',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularCounter(double progress, ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: _incrementCounter,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark 
                  ? const Color(0xFF0C1921).withValues(alpha: 0.45) 
                  : Colors.white.withValues(alpha: 0.45),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: _counter > 0 ? 0.15 : 0.05),
                  blurRadius: 30,
                  spreadRadius: 2,
                )
              ],
              border: Border.all(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.12) 
                    : Colors.white.withValues(alpha: 0.35),
                width: 0.5,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular progress bar track
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 7,
                    backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _counter >= _target ? AppTheme.successGreen : theme.colorScheme.primary,
                    ),
                  ),
                ),

                // Tap prompt & Counter value
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_counter',
                      style: TextStyle(
                        fontSize: 54,
                        color: _counter >= _target ? AppTheme.successGreen : theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'انقر للتسبيح',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons(ThemeData theme, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTargetOption(33, theme),
          _buildTargetOption(99, theme),
          _buildTargetOption(100, theme),
          _buildTargetOption(1000, theme),
        ],
      ),
    );
  }

  Widget _buildTargetOption(int value, ThemeData theme) {
    final isSelected = _target == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _target = value;
          _counter = 0; // reset current counter when changing target
        });
        _saveState();
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$value',
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
