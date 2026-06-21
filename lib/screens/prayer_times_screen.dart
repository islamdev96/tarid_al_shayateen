import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/prayer_time_settings.dart';
import '../providers/app_provider.dart';
import '../services/prayer_times_service.dart';
import '../widgets/mosque_header_widget.dart';
import '../widgets/glass_card.dart';
import '../widgets/glassy_background.dart';

/// Screen displaying the computed daily prayer times, countdown to the next prayer, and city config.
class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  Timer? _countdownTimer;
  Map<String, dynamic>? _nextPrayer;
  String _timeRemainingStr = '';

  @override
  void initState() {
    super.initState();
    _updateNextPrayer();
    // Refresh countdown every second
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateNextPrayer();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
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
    
    final city = provider.selectedCity;
    final prayerTimes = PrayerTimesService.calculate(city, DateTime.now());
    final list = prayerTimes.toList();

    return Scaffold(
      body: GlassyBackground(
        child: Stack(
          children: [
            const MosqueHeaderWidget(height: 200),
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  // Screen Header
                  SliverAppBar(
                    floating: true,
                    backgroundColor: Colors.transparent,
                    title: const Text('مواقيت الصلاة'),
                  ),

                  // Countdown Dashboard Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: _buildCountdownCard(theme),
                    ),
                  ),

                  // City Selector
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: _buildCitySelectorCard(provider, theme),
                    ),
                  ),

                  // Prayer Times List
                  SliverPadding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = list[index];
                          final prayerId = item['id'] as String;
                          final prayerName = item['name'] as String;
                          final prayerTime = item['time'] as DateTime;
                          
                          final isNext = _nextPrayer != null && _nextPrayer!['id'] == prayerId && _nextPrayer!['isTomorrow'] != true;
                          final isNotified = provider.prayerNotifications[prayerId] ?? (prayerId != 'sunrise');

                          return _buildPrayerTimeItem(prayerId, prayerName, prayerTime, isNext, isNotified, provider, theme);
                        },
                        childCount: list.length,
                      ),
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

  Widget _buildCountdownCard(ThemeData theme) {
    if (_nextPrayer == null) return const SizedBox.shrink();
    final prayerName = _nextPrayer!['name'] as String;
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
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppTheme.accentTeal : AppTheme.gold).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'الصلاة القادمة: صلاة $prayerName',
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
            'الوقت المتبقي لإقامة الصلاة في مدينة ${context.read<AppProvider>().selectedCity.nameAr}',
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

  Widget _buildCitySelectorCard(AppProvider provider, ThemeData theme) {
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
    AppProvider provider,
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
}
