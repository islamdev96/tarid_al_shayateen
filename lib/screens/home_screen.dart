import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import '../app_theme.dart';
import '../providers/settings_provider.dart';
import '../providers/prayer_times_provider.dart';
import '../providers/download_provider.dart';
import '../models/adhan_sound.dart';
import '../models/prayer_time_settings.dart';
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
import 'radio_screen.dart';
import 'audio_library_screen.dart';

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
    final downloadProvider = context.watch<DownloadProvider>();

    final city = prayerProvider.selectedCity;
    final prayerTimes = PrayerTimesService.calculate(city, DateTime.now());
    final list = prayerTimes.toList();

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

                        // Countdown Dashboard Card
                        _buildCountdownCard(theme, prayerProvider),
                        const SizedBox(height: 12),

                        // City Selector
                        _buildCitySelectorCard(prayerProvider, theme),
                        const SizedBox(height: 16),

                        // Daily Prayer Times Section
                        Text(
                          'مواقيت الصلاة اليوم',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 8),

                        // List of daily prayer times
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: list.map((item) {
                            final prayerId = item['id'] as String;
                            final prayerName = item['name'] as String;
                            final prayerTime = item['time'] as DateTime;
                            
                            final isNext = _nextPrayer != null && _nextPrayer!['id'] == prayerId && _nextPrayer!['isTomorrow'] != true;
                            final isNotified = prayerProvider.prayerNotifications[prayerId] ?? (prayerId != 'sunrise');

                            return _buildPrayerTimeItem(prayerId, prayerName, prayerTime, isNext, isNotified, prayerProvider, theme);
                          }).toList(),
                        ),
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

  Widget _buildCountdownCard(ThemeData theme, PrayerTimesProvider provider) {
    if (_nextPrayer == null) return const SizedBox.shrink();
    final prayerName = _nextPrayer!['name'] as String;
    final prayerId = _nextPrayer!['id'] as String;
    final isSunrise = prayerId == 'sunrise';
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isDark ? AppTheme.cyanGradient : AppTheme.goldGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            isSunrise ? 'الحدث القادم: وقت الشروق' : 'الصلاة القادمة: صلاة $prayerName',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _timeRemainingStr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSunrise
                ? 'الوقت المتبقي لشروق الشمس في مدينة ${provider.selectedCity.nameAr}'
                : 'الوقت المتبقي لإقامة الصلاة في مدينة ${provider.selectedCity.nameAr}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitySelectorCard(PrayerTimesProvider provider, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: BorderRadius.circular(16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.selectedCity.id,
          icon: Icon(CupertinoIcons.location_solid, color: theme.colorScheme.primary, size: 20),
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
          dropdownColor: isDark 
              ? const Color(0xFF0C1921)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          onChanged: (String? newCityId) {
            if (newCityId != null) {
              provider.updateSelectedCity(newCityId);
              _updateNextPrayer();
            }
          },
          items: CityConfig.defaultCities.map<DropdownMenuItem<String>>((CityConfig city) {
            return DropdownMenuItem<String>(
              value: city.id,
              child: Text('المدينة: ${city.nameAr}'),
            );
          }).toList(),
        ),
      ),
    );
  }


  Widget _buildPrayerTimeItem(
    String id,
    String name,
    DateTime time,
    bool isNext,
    bool isNotified,
    PrayerTimesProvider provider,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      border: Border.all(
        color: isNext
            ? theme.colorScheme.primary.withValues(alpha: 0.6)
            : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.25)),
        width: isNext ? 1.5 : 0.5,
      ),
      color: isNext
          ? theme.colorScheme.primary.withValues(alpha: 0.12)
          : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isNext
                ? theme.colorScheme.primary.withValues(alpha: 0.25)
                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
            border: Border.all(
              color: isNext
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
              width: 0.5,
            ),
          ),
          child: Center(
            child: Icon(
              _getPrayerIcon(id),
              color: isNext ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              size: 18,
            ),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            color: isNext ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'Cairo',
          ),
        ),
        subtitle: isNext
            ? const Text(
                'الصلاة القادمة',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 11,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatTime(time),
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            // Hide notification switch for Sunrise since it has no Adhan
            if (id != 'sunrise')
              IconButton(
                icon: Icon(
                  isNotified
                      ? CupertinoIcons.bell_fill
                      : CupertinoIcons.bell_slash,
                  color: isNotified ? theme.colorScheme.primary : theme.disabledColor,
                  size: 18,
                ),
                onPressed: () => provider.togglePrayerNotification(id),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getPrayerIcon(String id) {
    switch (id) {
      case 'fajr':
        return CupertinoIcons.sunrise;
      case 'sunrise':
        return CupertinoIcons.sun_min;
      case 'dhuhr':
        return CupertinoIcons.sun_max_fill;
      case 'asr':
        return CupertinoIcons.cloud_sun_fill;
      case 'maghrib':
        return CupertinoIcons.sunset_fill;
      case 'isha':
        return CupertinoIcons.moon_stars_fill;
      default:
        return CupertinoIcons.clock;
    }
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
          icon: CupertinoIcons.music_note_list,
          label: 'المكتبة الصوتية',
          darkColor: const Color(0xFF5E5CE6),
          lightColor: const Color(0xFF5856D6),
          onTap: () {
            Navigator.push(context, CupertinoPageRoute(builder: (_) => const AudioLibraryScreen()));
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
