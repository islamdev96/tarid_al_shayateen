import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/schedule_settings.dart';
import '../providers/settings_provider.dart';
import '../providers/app_provider.dart';
import '../models/prayer_time_settings.dart';
import '../models/adhan_sound.dart';
import '../widgets/glass_card.dart';
import '../widgets/glassy_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ScheduleSettings _draft;
  late bool _azkarReminderEnabled;
  late TimeOfDay _azkarMorningTime;
  late TimeOfDay _azkarEveningTime;
  int _activeTabIndex = 0;
  final List<String> _tabNames = ['التشغيل والأذكار', 'الصلاة والموقع', 'الأصوات والنظام'];

  @override
  void initState() {
    super.initState();
    final provider = context.read<SettingsProvider>();
    _draft = provider.settings;
    _azkarReminderEnabled = provider.isAzkarReminderEnabled;
    _azkarMorningTime = provider.azkarMorningTime;
    _azkarEveningTime = provider.azkarEveningTime;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'م' : 'ص';
    final formattedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$formattedHour:$minute $period';
  }

  void _save({bool showMessage = false}) {
    final provider = context.read<SettingsProvider>();
    provider.updateSettings(_draft);
    
    // Save Azkar reminders settings
    provider.updateAzkarReminderSettings(
      isEnabled: _azkarReminderEnabled,
      morningTime: _azkarMorningTime,
      eveningTime: _azkarEveningTime,
    );

    if (showMessage) {
      final nextTime = _draft.getNextPlaybackTime();
      if (nextTime != null) {
        final hour = nextTime.hour;
        final minute = nextTime.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'م' : 'ص';
        final formattedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        final timeStr = '$formattedHour:$minute $period';
        final dateStr = '${nextTime.year}-${nextTime.month.toString().padLeft(2, '0')}-${nextTime.day.toString().padLeft(2, '0')}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم الجدولة التلقائية يوم $dateStr الساعة $timeStr', style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم الحفظ التلقائي للإعدادات', style: TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: GlassyBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_rounded, color: theme.colorScheme.primary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'الإعدادات العامة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),

              // Sliding TabBar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.black12,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: List.generate(_tabNames.length, (index) {
                    final isSelected = _activeTabIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _activeTabIndex = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              _tabNames[index],
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 8),

              // Tab Contents
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: _buildTabContent(theme),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTabContent(ThemeData theme) {
    switch (_activeTabIndex) {
      case 0:
        return [
          const SizedBox(height: 8),
          _buildSectionHeader('جدولة تشغيل سورة البقرة', theme),
          const SizedBox(height: 8),
          _buildEnableToggle(theme),
          if (_draft.isEnabled) ...[
            const SizedBox(height: 16),
            _buildTimePicker(theme),
            const SizedBox(height: 16),
            _buildRepeatModeSelector(theme),
            const SizedBox(height: 16),
            if (_draft.repeatMode == RepeatMode.everyXDays) _buildIntervalSelector(theme),
            if (_draft.repeatMode == RepeatMode.weekDays) _buildWeekDaySelector(theme),
            const SizedBox(height: 24),
            _buildPreview(theme),
          ],
          const Divider(height: 40),
          _buildSectionHeader('تنبيهات الأذكار اليومية', theme),
          const SizedBox(height: 8),
          _buildAzkarReminderToggle(theme),
          if (_azkarReminderEnabled) ...[
            const SizedBox(height: 16),
            _buildAzkarMorningTimePicker(theme),
            const SizedBox(height: 16),
            _buildAzkarEveningTimePicker(theme),
          ],
          const SizedBox(height: 120),
        ];
      case 1:
        return [
          const SizedBox(height: 8),
          _buildSectionHeader('إعدادات الموقع ومواقيت الصلاة', theme),
          const SizedBox(height: 8),
          _buildLocationSettingsCard(theme),
          const SizedBox(height: 120),
        ];
      case 2:
        return [
          const SizedBox(height: 8),
          _buildSectionHeader('أصوات الأذان والتنبيهات', theme),
          const SizedBox(height: 8),
          _buildPrePrayerReminderCard(theme),
          const SizedBox(height: 16),
          _buildFlipToMuteCard(theme),
          const SizedBox(height: 16),
          _buildAdhanPerPrayerCard(theme),
          const Divider(height: 40),
          _buildSectionHeader('تحسين العمل في الخلفية', theme),
          const SizedBox(height: 8),
          _buildBatteryOptimizationCard(theme),
          const SizedBox(height: 120),
        ];
      default:
        return [];
    }
  }

  Widget _buildEnableToggle(ThemeData theme) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          Icon(CupertinoIcons.power, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'تفعيل الجدولة التلقائية', 
              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Cairo'),
            ),
          ),
          CupertinoSwitch(
            value: _draft.isEnabled,
            activeTrackColor: theme.colorScheme.primary,
            onChanged: (v) {
              setState(() => _draft = _draft.copyWith(isEnabled: v));
              _save();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(ThemeData theme) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _draft.playbackTime,
          builder: (context, child) {
            return Theme(
              data: theme.copyWith(
                timePickerTheme: TimePickerThemeData(
                  backgroundColor: theme.colorScheme.surface,
                  dialHandColor: theme.colorScheme.primary,
                  hourMinuteColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                  hourMinuteTextColor: theme.colorScheme.primary,
                  dayPeriodColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                  dayPeriodTextColor: theme.colorScheme.primary,
                ),
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              ),
            );
          },
        );
        if (picked != null) {
          setState(() => _draft = _draft.copyWith(playbackTime: picked));
          _save(showMessage: true);
        }
      },
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Icon(CupertinoIcons.clock, color: theme.colorScheme.secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'وقت التشغيل', 
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Cairo'),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 0.5),
              ),
              child: Text(
                _formatTimeOfDay(_draft.playbackTime),
                style: TextStyle(color: theme.colorScheme.primary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatModeSelector(ThemeData theme) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.repeat, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'نمط التكرار', 
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Cairo'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildModeOption(RepeatMode.daily, 'كل يوم', CupertinoIcons.calendar, theme),
          const SizedBox(height: 8),
          _buildModeOption(RepeatMode.everyXDays, 'كل عدد أيام معين', CupertinoIcons.calendar_today, theme),
          const SizedBox(height: 8),
          _buildModeOption(RepeatMode.weekDays, 'أيام معينة في الأسبوع', CupertinoIcons.square_grid_2x2, theme),
        ],
      ),
    );
  }

  Widget _buildModeOption(RepeatMode mode, String label, IconData icon, ThemeData theme) {
    final isSelected = _draft.repeatMode == mode;
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        setState(() => _draft = _draft.copyWith(repeatMode: mode));
        _save();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              size: 20, 
              color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodySmall?.color,
            ),
            const SizedBox(width: 12),
            Text(
              label, 
              style: TextStyle(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface, 
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontFamily: 'Cairo',
              ),
            ),
            const Spacer(),
            if (isSelected) Icon(CupertinoIcons.checkmark_circle_fill, color: theme.colorScheme.primary, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalSelector(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.number, color: theme.colorScheme.secondary),
              const SizedBox(width: 12),
              Text(
                'كل ${_draft.intervalDays} أيام', 
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Cairo'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: _draft.intervalDays.toDouble(),
            min: 1, max: 14, divisions: 13,
            label: '${_draft.intervalDays} أيام',
            activeColor: theme.colorScheme.primary,
            inactiveColor: isDark 
                ? Colors.white.withValues(alpha: 0.1) 
                : Colors.black.withValues(alpha: 0.08),
            onChanged: (v) => setState(() => _draft = _draft.copyWith(intervalDays: v.toInt())),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('يوم', style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12, fontFamily: 'Cairo')),
              Text('${_draft.intervalDays}', style: TextStyle(color: theme.colorScheme.primary, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              Text('١٤ يوم', style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12, fontFamily: 'Cairo')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaySelector(ThemeData theme) {
    final dayNames = {1: 'الاثنين', 2: 'الثلاثاء', 3: 'الأربعاء', 4: 'الخميس', 5: 'الجمعة', 6: 'السبت', 7: 'الأحد'};
    final shortNames = {1: 'اث', 2: 'ثل', 3: 'أر', 4: 'خم', 5: 'جم', 6: 'سب', 7: 'أح'};
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.calendar_today, color: theme.colorScheme.secondary),
              const SizedBox(width: 12),
              Text(
                'اختر الأيام', 
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Cairo'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: dayNames.entries.map((entry) {
              final isSelected = _draft.selectedWeekDays.contains(entry.key);
              return GestureDetector(
                onTap: () {
                  final newDays = Set<int>.from(_draft.selectedWeekDays);
                  if (isSelected) { newDays.remove(entry.key); } else { newDays.add(entry.key); }
                  setState(() => _draft = _draft.copyWith(selectedWeekDays: newDays));
                  _save();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? theme.colorScheme.primary 
                          : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    shortNames[entry.key]!, 
                    style: TextStyle(
                      color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodySmall?.color, 
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal, 
                      fontSize: 13,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(CupertinoIcons.info_circle, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _draft.getScheduleDescription(),
              style: TextStyle(color: theme.colorScheme.primary, fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 12, right: 4),
      child: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildAzkarReminderToggle(ThemeData theme) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          Icon(CupertinoIcons.bell_fill, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'تفعيل تنبيهات الأذكار',
              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Cairo'),
            ),
          ),
          CupertinoSwitch(
            value: _azkarReminderEnabled,
            activeTrackColor: theme.colorScheme.primary,
            onChanged: (v) {
              setState(() => _azkarReminderEnabled = v);
              _save();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAzkarMorningTimePicker(ThemeData theme) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _azkarMorningTime,
          builder: (context, child) {
            return Theme(
              data: theme.copyWith(
                timePickerTheme: TimePickerThemeData(
                  backgroundColor: theme.colorScheme.surface,
                  dialHandColor: theme.colorScheme.primary,
                  hourMinuteColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                  hourMinuteTextColor: theme.colorScheme.primary,
                  dayPeriodColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                  dayPeriodTextColor: theme.colorScheme.primary,
                ),
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              ),
            );
          },
        );
        if (picked != null) {
          setState(() => _azkarMorningTime = picked);
          _save(showMessage: true);
        }
      },
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Icon(CupertinoIcons.sun_max_fill, color: theme.colorScheme.secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'وقت تنبيه أذكار الصباح',
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Cairo'),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 0.5),
              ),
              child: Text(
                _formatTimeOfDay(_azkarMorningTime),
                style: TextStyle(color: theme.colorScheme.primary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAzkarEveningTimePicker(ThemeData theme) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _azkarEveningTime,
          builder: (context, child) {
            return Theme(
              data: theme.copyWith(
                timePickerTheme: TimePickerThemeData(
                  backgroundColor: theme.colorScheme.surface,
                  dialHandColor: theme.colorScheme.primary,
                  hourMinuteColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                  hourMinuteTextColor: theme.colorScheme.primary,
                  dayPeriodColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                  dayPeriodTextColor: theme.colorScheme.primary,
                ),
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              ),
            );
          },
        );
        if (picked != null) {
          setState(() => _azkarEveningTime = picked);
          _save(showMessage: true);
        }
      },
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Icon(CupertinoIcons.moon_fill, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'وقت تنبيه أذكار المساء',
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Cairo'),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 0.5),
              ),
              child: Text(
                _formatTimeOfDay(_azkarEveningTime),
                style: TextStyle(color: theme.colorScheme.primary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryOptimizationCard(ThemeData theme) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.battery_alert_rounded, color: theme.colorScheme.secondary, size: 24),
              const SizedBox(width: 10),
              Text(
                'استثناء التطبيق من توفير البطارية',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'أنظمة التشغيل الحديثة (خاصة Android 13/14+) تقوم بإغلاق العمليات الخلفية للحفاظ على البطارية، مما قد يعطل تشغيل سورة البقرة أو الأذان في وقته بدقة.\n\nتأكد من إعطاء الصلاحية واختيار "غير مقيد" (Unrestricted) للتطبيق من إعدادات بطارية الهاتف.',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 13,
              height: 1.6,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final isGranted = await Permission.ignoreBatteryOptimizations.isGranted;
              if (!isGranted) {
                await Permission.ignoreBatteryOptimizations.request();
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('الصلاحية مفعلة بالفعل للتطبيق', style: TextStyle(fontFamily: 'Cairo')),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                }
              }
            },
            icon: const Icon(CupertinoIcons.battery_charging, size: 18),
            label: const Text(
              'تفعيل الاستثناء من الإعدادات',
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSettingsCard(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final appProvider = context.watch<AppProvider>();
    final isAutomatic = appProvider.locationMode == 'automatic';

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.location_solid, color: theme.colorScheme.secondary, size: 24),
              const SizedBox(width: 10),
              Text(
                'تحديد الموقع الجغرافي',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Switch between Manual and Automatic
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    await appProvider.setLocationMode('manual');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !isAutomatic
                          ? theme.colorScheme.primary.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: !isAutomatic
                            ? theme.colorScheme.primary
                            : (isDark ? Colors.white12 : Colors.black12),
                      ),
                    ),
                    child: Text(
                      'يدوي (مدينة)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: !isAutomatic ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    await _updateGpsLocation(appProvider);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isAutomatic
                          ? theme.colorScheme.primary.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isAutomatic
                            ? theme.colorScheme.primary
                            : (isDark ? Colors.white12 : Colors.black12),
                      ),
                    ),
                    child: Text(
                      'تلقائي (GPS)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isAutomatic ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (isAutomatic) ...[
            Text(
              'الموقع الحالي المحدد بالـ GPS:\nخط العرض: ${appProvider.gpsLatitude.toStringAsFixed(4)}\nخط الطول: ${appProvider.gpsLongitude.toStringAsFixed(4)}',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                height: 1.6,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                foregroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _updateGpsLocation(appProvider),
              icon: const Icon(CupertinoIcons.location_circle, size: 18),
              label: const Text(
                'تحديث الموقع الحالي (GPS)',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ] else ...[
            Text(
              'اختر المدينة لحساب مواقيت الصلاة يدوياً:',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: appProvider.selectedCity.id == 'gps' ? 'cairo' : appProvider.selectedCity.id,
                  isExpanded: true,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontFamily: 'Cairo',
                    fontSize: 14,
                  ),
                  dropdownColor: isDark ? const Color(0xFF0C1921) : Colors.white,
                  onChanged: (String? newCityId) {
                    if (newCityId != null) {
                      final city = CityConfig.defaultCities.firstWhere((c) => c.id == newCityId);
                      appProvider.updateSelectedCity(city);
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
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _updateGpsLocation(AppProvider provider) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('الرجاء تفعيل خدمات الموقع (GPS) في الهاتف', style: TextStyle(fontFamily: 'Cairo'))),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم رفض صلاحيات الوصول للموقع', style: TextStyle(fontFamily: 'Cairo'))),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('صلاحيات الموقع مرفوضة دائماً، الرجاء تفعيلها من إعدادات الهاتف', style: TextStyle(fontFamily: 'Cairo'))),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('جاري جلب إحداثيات الموقع الحالي...', style: TextStyle(fontFamily: 'Cairo')), duration: Duration(seconds: 1)),
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await provider.updateGpsCoordinates(position.latitude, position.longitude);
      await provider.setLocationMode('automatic');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الموقع الجغرافي وحساب المواقيت بدقة ✅', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: AppTheme.successGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في جلب الموقع: $e', style: const TextStyle(fontFamily: 'Cairo'))),
        );
      }
    }
  }

  Widget _buildPrePrayerReminderCard(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final appProvider = context.watch<AppProvider>();
    final offset = appProvider.prePrayerReminderOffset;
    final type = appProvider.prePrayerReminderType;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.bell_circle_fill, color: theme.colorScheme.secondary, size: 24),
              const SizedBox(width: 10),
              Text(
                'التذكير قبل وقت الصلاة',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Dropdown for offset time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'تنبيه مسبق بـ:',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: offset,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontFamily: 'Cairo',
                      fontSize: 13,
                    ),
                    dropdownColor: isDark ? const Color(0xFF0C1921) : Colors.white,
                    onChanged: (int? newOffset) {
                      if (newOffset != null) {
                        appProvider.updatePrePrayerReminder(newOffset, type);
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('إيقاف التنبيه المسبق')),
                      DropdownMenuItem(value: 5, child: Text('5 دقائق')),
                      DropdownMenuItem(value: 10, child: Text('10 دقائق')),
                      DropdownMenuItem(value: 15, child: Text('15 دقيقة')),
                      DropdownMenuItem(value: 20, child: Text('20 دقيقة')),
                      DropdownMenuItem(value: 30, child: Text('30 دقيقة')),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (offset > 0) ...[
            const SizedBox(height: 16),
            // Dropdown for alert type
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'نوع التنبيه المسبق:',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: type,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontFamily: 'Cairo',
                        fontSize: 13,
                      ),
                      dropdownColor: isDark ? const Color(0xFF0C1921) : Colors.white,
                      onChanged: (String? newType) {
                        if (newType != null) {
                          appProvider.updatePrePrayerReminder(offset, newType);
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: 'notification_only', child: Text('إشعار فقط')),
                        DropdownMenuItem(value: 'sound', child: Text('رنة تنبيه قصيرة')),
                        DropdownMenuItem(value: 'voice_alert', child: Text('نطق صوتي (اقتربت الصلاة)')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFlipToMuteCard(ThemeData theme) {
    final appProvider = context.watch<AppProvider>();
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          Icon(CupertinoIcons.device_phone_portrait, color: theme.colorScheme.secondary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إيقاف الأذان عند قلب الهاتف',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  'اقلب الهاتف وجهاً لأسفل لكتم الأذان فوراً عند تشغيله',
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: appProvider.flipToMuteEnabled,
            onChanged: (val) {
              appProvider.updateFlipToMute(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdhanPerPrayerCard(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final appProvider = context.watch<AppProvider>();
    
    final prayers = [
      {'id': 'fajr', 'name': 'صلاة الفجر'},
      {'id': 'dhuhr', 'name': 'صلاة الظهر'},
      {'id': 'asr', 'name': 'صلاة العصر'},
      {'id': 'maghrib', 'name': 'صلاة المغرب'},
      {'id': 'isha', 'name': 'صلاة العشاء'},
    ];

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.music_mic, color: theme.colorScheme.secondary, size: 24),
              const SizedBox(width: 10),
              Text(
                'تخصيص الأذان لكل صلاة',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Unify all adhan sounds option
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'توحيد مؤذن جميع الصلوات',
                      style: TextStyle(
                        fontFamily: 'Cairo', 
                        fontSize: 13, 
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    Text(
                      'تطبيق صوت مؤذن واحد على جميع أوقات الصلوات دفعة واحدة',
                      style: TextStyle(
                        fontFamily: 'Cairo', 
                        fontSize: 10,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: const Text(
                      'اختر لتوحيد الصوت',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontFamily: 'Cairo',
                      fontSize: 12,
                    ),
                    dropdownColor: isDark ? const Color(0xFF0C1921) : Colors.white,
                    onChanged: (String? newAdhanId) {
                      if (newAdhanId != null) {
                        for (final prayer in prayers) {
                          appProvider.updatePrayerAdhanId(prayer['id']!, newAdhanId);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم توحيد صوت الأذان لجميع الصلوات بنجاح', style: TextStyle(fontFamily: 'Cairo')),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    items: AdhanSound.defaultAdhans.map((AdhanSound adhan) {
                      return DropdownMenuItem(
                        value: adhan.id,
                        child: Text(adhan.nameAr),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white24),
          ),
          
          Text(
            'أو تخصيص مؤذن لكل صلاة بشكل مستقل:',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              fontSize: 12,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 12),
          ...prayers.map((prayer) {
            final prayerId = prayer['id']!;
            final prayerName = prayer['name']!;
            final currentAdhanId = appProvider.getPrayerAdhanId(prayerId);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    prayerName,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: currentAdhanId,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontFamily: 'Cairo',
                          fontSize: 12,
                        ),
                        dropdownColor: isDark ? const Color(0xFF0C1921) : Colors.white,
                        onChanged: (String? newAdhanId) {
                          if (newAdhanId != null) {
                            appProvider.updatePrayerAdhanId(prayerId, newAdhanId);
                          }
                        },
                        items: AdhanSound.defaultAdhans.map((AdhanSound adhan) {
                          return DropdownMenuItem(
                            value: adhan.id,
                            child: Text(adhan.nameAr),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
