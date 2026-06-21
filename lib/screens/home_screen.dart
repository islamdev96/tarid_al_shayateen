import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import '../app_theme.dart';
import '../providers/app_provider.dart';
import '../services/prayer_times_service.dart';
import '../widgets/hadith_card.dart';
import 'azkar_screen.dart';
import 'quran_screen.dart';
import 'qiblah_screen.dart';
import 'baqarah_fortification_screen.dart';

/// The redesigned Home screen displaying a premium dashboard.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _prayerTimer;
  Map<String, dynamic>? _nextPrayer;
  String _timeRemainingStr = '';

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _updateNextPrayer();
    _prayerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateNextPrayer();
    });
  }

  @override
  void dispose() {
    _prayerTimer?.cancel();
    super.dispose();
  }

  void _updateNextPrayer() {
    if (!mounted) return;
    final provider = context.read<AppProvider>();
    final city = provider.selectedCity;
    
    final next = PrayerTimesService.getNextPrayer(city);
    if (next != null) {
      final nextTime = next['time'] as DateTime;
      final diff = nextTime.difference(DateTime.now());
      
      if (diff.inSeconds > 0) {
        final hours = diff.inHours;
        final minutes = diff.inMinutes % 60;
        final seconds = diff.inSeconds % 60;
        
        setState(() {
          _nextPrayer = next;
          _timeRemainingStr = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        });
      } else {
        setState(() {
          _nextPrayer = next;
          _timeRemainingStr = '00:00:00';
        });
      }
    }
  }

  Future<void> _requestPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyShown = prefs.getBool('permissions_requested') ?? false;
    if (alreadyShown || !mounted) return;

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    await prefs.setBool('permissions_requested', true);
    
    // Request notification permission (Android 13+)
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Check if battery optimization is enabled
    if (!await Permission.ignoreBatteryOptimizations.isGranted && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.battery_alert_rounded, color: AppTheme.gold),
              SizedBox(width: 8),
              Text('صلاحية هامة للتنبيه', style: TextStyle(color: AppTheme.gold, fontSize: 18)),
            ],
          ),
          content: const Text(
            'لضمان عمل التنبيه في وقته بالثانية وإنت قافل التطبيق، نحتاج إعطاء التطبيق صلاحية (العمل في الخلفية / استثناء من توفير البطارية).\n\nاضغط "تفعيل" ثم "سماح" (Allow).',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('تخطي', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentTeal,
                foregroundColor: AppTheme.deepBackground,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await Permission.ignoreBatteryOptimizations.request();
              },
              child: const Text('تفعيل الصلاحية', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'م' : 'ص';
    final formattedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$formattedHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(context)),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Beautiful Custom Header
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                title: Row(
                  children: [
                    Text(
                      'سَكينة',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        provider.isDarkMode
                            ? Icons.wb_sunny_rounded
                            : Icons.mode_night_rounded,
                      ),
                      color: provider.isDarkMode ? AppTheme.gold : AppTheme.lightGold,
                      onPressed: () => provider.toggleThemeMode(),
                    ),
                  ],
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 12),

                    // Bismillah Header
                    _buildBismillahHeader(theme),
                    const SizedBox(height: 16),

                    // Next Prayer Card (Quick Summary)
                    _buildNextPrayerCard(theme, provider),
                    const SizedBox(height: 20),

                    // Quick Actions Grid (2x2)
                    _buildQuickActionsGrid(context, theme),
                    const SizedBox(height: 20),

                    // Hadith Card
                    const HadithCard(),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBismillahHeader(ThemeData theme) {
    return Text(
      'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 22,
        fontFamily: 'serif',
        color: theme.brightness == Brightness.dark ? AppTheme.gold : AppTheme.primaryGreen,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildNextPrayerCard(ThemeData theme, AppProvider provider) {
    if (_nextPrayer == null) return const SizedBox.shrink();
    
    final isDark = theme.brightness == Brightness.dark;
    final name = _nextPrayer!['name'] as String;
    final time = _nextPrayer!['time'] as DateTime;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCard(context),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الصلاة القادمة: صلاة $name',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'المتبقي: $_timeRemainingStr',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'المدينة: ${provider.selectedCity.nameAr} • الأذان في ${_formatTime(time)}',
                  style: TextStyle(
                    color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
                    fontSize: 11,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
            ),
            child: Icon(Icons.access_time_filled_rounded, color: theme.colorScheme.primary, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, ThemeData theme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: [
        _buildActionItem(
          icon: Icons.menu_book_rounded,
          label: 'القرآن الكريم',
          color: theme.colorScheme.primary,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const QuranScreen()));
          },
          theme: theme,
        ),
        _buildActionItem(
          icon: Icons.shield_rounded,
          label: 'أذكار اليوم',
          color: AppTheme.accentTeal,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AzkarScreen()));
          },
          theme: theme,
        ),
        _buildActionItem(
          icon: Icons.explore_rounded,
          label: 'اتجاه القبلة',
          color: Colors.amber,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const QiblahScreen()));
          },
          theme: theme,
        ),
        _buildActionItem(
          icon: Icons.security_rounded,
          label: 'حصن البيت',
          color: theme.colorScheme.secondary,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BaqarahFortificationScreen()));
          },
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: AppTheme.glassCard(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
