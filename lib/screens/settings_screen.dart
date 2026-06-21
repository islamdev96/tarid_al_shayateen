import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/schedule_settings.dart';
import '../providers/app_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/glassy_background.dart';

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

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _draft = provider.settings;
    _azkarReminderEnabled = provider.isAzkarReminderEnabled;
    _azkarMorningTime = provider.azkarMorningTime;
    _azkarEveningTime = provider.azkarEveningTime;
  }

  void _save() {
    final provider = context.read<AppProvider>();
    provider.updateSettings(_draft);
    
    // Save Azkar reminders settings
    provider.updateAzkarReminderSettings(
      isEnabled: _azkarReminderEnabled,
      morningTime: _azkarMorningTime,
      eveningTime: _azkarEveningTime,
    );

    final nextTime = _draft.getNextPlaybackTime();
    if (nextTime != null) {
      final timeStr = '${nextTime.hour.toString().padLeft(2, '0')}:${nextTime.minute.toString().padLeft(2, '0')}';
      final dateStr = '${nextTime.year}-${nextTime.month.toString().padLeft(2, '0')}-${nextTime.day.toString().padLeft(2, '0')}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ الإعدادات بنجاح وجدولة تشغيل سورة البقرة يوم $dateStr الساعة $timeStr', style: const TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppTheme.accentTeal,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ إعدادات التطبيق بنجاح', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppTheme.accentTeal,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: GlassyBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                title: const Text('الإعدادات'),
                actions: [
                  TextButton(
                    onPressed: _save,
                    child: Text('حفظ', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
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
                    const SizedBox(height: 120), // Padding to avoid overlap with mini player
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
            onChanged: (v) => setState(() => _draft = _draft.copyWith(isEnabled: v)),
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
                '${_draft.playbackTime.hour.toString().padLeft(2, '0')}:${_draft.playbackTime.minute.toString().padLeft(2, '0')}',
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
      onTap: () => setState(() => _draft = _draft.copyWith(repeatMode: mode)),
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
            onChanged: (v) => setState(() => _azkarReminderEnabled = v),
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
        }
      },
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Icon(CupertinoIcons.sun_max_fill, color: theme.brightness == Brightness.dark ? AppTheme.gold : AppTheme.lightGold),
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
                '${_azkarMorningTime.hour.toString().padLeft(2, '0')}:${_azkarMorningTime.minute.toString().padLeft(2, '0')}',
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
        }
      },
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Icon(CupertinoIcons.moon_fill, color: AppTheme.accentTeal),
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
                '${_azkarEveningTime.hour.toString().padLeft(2, '0')}:${_azkarEveningTime.minute.toString().padLeft(2, '0')}',
                style: TextStyle(color: theme.colorScheme.primary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
