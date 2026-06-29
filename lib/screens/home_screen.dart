import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import '../app_theme.dart';
import '../ui/app_icons.dart';
import '../providers/settings_provider.dart';
import '../providers/prayer_times_provider.dart';
import '../services/prayer_times_service.dart';
import '../widgets/hadith_card.dart';
import '../widgets/glass_card.dart';
import '../widgets/glassy_background.dart';
import '../widgets/mosque_header_widget.dart';
import 'azkar_screen.dart';
import 'quran_screen.dart';
import 'qiblah_screen.dart';
import 'baqarah_fortification_screen.dart';
import 'tasbeeh_screen.dart';
import 'prayer_times_screen.dart';
import 'radio_screen.dart';

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
    final provider = context.read<PrayerTimesProvider>();
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
    if (kIsWeb) return; // Permissions not needed/supported on web
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
        builder: (ctx) {
          final dialogTheme = Theme.of(ctx);
          final isDark = dialogTheme.brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.battery_alert_rounded, color: dialogTheme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text('صلاحية هامة للتنبيه', style: TextStyle(color: dialogTheme.colorScheme.secondary, fontSize: 18)),
              ],
            ),
            content: Text(
              'لضمان عمل التنبيه في وقته بالثانية وإنت قافل التطبيق، نحتاج إعطاء التطبيق صلاحية (العمل في الخلفية / استثناء من توفير البطارية).\n\nاضغط "تفعيل" ثم "سماح" (Allow).',
              style: TextStyle(color: dialogTheme.colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14, height: 1.6),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('تخطي', style: TextStyle(color: dialogTheme.colorScheme.onSurface.withValues(alpha: 0.4))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: dialogTheme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await Permission.ignoreBatteryOptimizations.request();
                },
                child: const Text('تفعيل الصلاحية', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
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
    final settingsProvider = context.watch<SettingsProvider>();
    final prayerProvider = context.watch<PrayerTimesProvider>();

    return Scaffold(
      body: GlassyBackground(
        child: Stack(
          children: [
            // Mosque silhouette header (behind content)
            const MosqueHeaderWidget(height: 220),

            // Scrollable content
            SafeArea(
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
                            settingsProvider.isDarkMode
                                ? CupertinoIcons.sun_max_fill
                                : CupertinoIcons.moon_fill,
                          ),
                          color: settingsProvider.isDarkMode ? AppTheme.accentTeal : AppTheme.lightGold,
                          onPressed: () => settingsProvider.toggleThemeMode(),
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
                        _buildNextPrayerCard(theme, prayerProvider),
                        const SizedBox(height: 20),

                        // Quick Actions Grid (2x2)
                        _buildQuickActionsGrid(context, theme),
                        const SizedBox(height: 20),

                        // Hadith Card
                        const HadithCard(),
                        const SizedBox(height: 110), // Bottom padding to prevent collision with extendBody mini player
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBismillahHeader(ThemeData theme) {
    return Text(
      'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 22,
        fontFamily: 'serif',
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildNextPrayerCard(ThemeData theme, PrayerTimesProvider provider) {
    if (_nextPrayer == null) return const SizedBox.shrink();
    
    final isDark = theme.brightness == Brightness.dark;
    final name = _nextPrayer!['name'] as String;
    final time = _nextPrayer!['time'] as DateTime;

    return GlassCard(
      padding: const EdgeInsets.all(20),
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
                    fontSize: 18,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'المتبقي: $_timeRemainingStr',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'المدينة: ${provider.selectedCity.nameAr} • الأذان في ${_formatTime(time)}',
                  style: TextStyle(
                    color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
                    fontSize: 13,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
            ),
            child: Icon(CupertinoIcons.clock_fill, color: theme.colorScheme.primary, size: 30),
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
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.25,
      children: [
        _buildActionItem(
          icon: CupertinoIcons.book,
          label: 'القرآن الكريم',
          darkColor: const Color(0xFF5AC8FA),
          lightColor: const Color(0xFF007AFF),
          onTap: () {
            Navigator.push(context, CupertinoPageRoute(builder: (_) => const QuranScreen()));
          },
          theme: theme,
        ),
        _buildActionItem(
          icon: CupertinoIcons.shield,
          label: 'حصن المسلم',
          darkColor: const Color(0xFF30D158),
          lightColor: const Color(0xFF34C759),
          onTap: () {
            Navigator.push(context, CupertinoPageRoute(builder: (_) => const AzkarScreen()));
          },
          theme: theme,
        ),
        _buildActionItem(
          icon: CupertinoIcons.compass,
          label: 'اتجاه القبلة',
          darkColor: const Color(0xFF40CBE0),
          lightColor: const Color(0xFF30B0C7),
          onTap: () {
            Navigator.push(context, CupertinoPageRoute(builder: (_) => const QiblahScreen()));
          },
          theme: theme,
        ),
        _buildActionItem(
          icon: CupertinoIcons.shield_fill,
          label: 'حصن البيت',
          darkColor: const Color(0xFFFFD60A),
          lightColor: const Color(0xFFFF9500),
          onTap: () {
            Navigator.push(context, CupertinoPageRoute(builder: (_) => const BaqarahFortificationScreen()));
          },
          theme: theme,
        ),
        _buildActionItem(
          icon: CupertinoIcons.alarm,
          label: 'مواقيت الصلاة',
          darkColor: const Color(0xFF5E5CE6),
          lightColor: const Color(0xFF5856D6),
          onTap: () {
            Navigator.push(context, CupertinoPageRoute(builder: (_) => const PrayerTimesScreen()));
          },
          theme: theme,
        ),
        _buildActionItem(
          icon: CupertinoIcons.infinite,
          label: 'المسبحة',
          darkColor: const Color(0xFFBF5AF2),
          lightColor: const Color(0xFFAF52DE),
          onTap: () {
            Navigator.push(context, CupertinoPageRoute(builder: (_) => const TasbeehScreen()));
          },
          theme: theme,
        ),
        _buildActionItem(
          icon: CupertinoIcons.antenna_radiowaves_left_right,
          label: 'إذاعة القرآن',
          darkColor: const Color(0xFFFF9F0A),
          lightColor: const Color(0xFFFF9500),
          onTap: () {
            Navigator.push(context, CupertinoPageRoute(builder: (_) => const RadioScreen()));
          },
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color darkColor,
    required Color lightColor,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final color = isDark ? darkColor : lightColor;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: isDark ? 0.15 : 0.12),
                border: Border.all(
                  color: color.withValues(alpha: isDark ? 0.25 : 0.18),
                  width: 0.5,
                ),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
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
