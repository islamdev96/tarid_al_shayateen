import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/schedule_settings.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ScheduleSettings _draft;

  @override
  void initState() {
    super.initState();
    _draft = context.read<AppProvider>().settings;
  }

  void _save() {
    final provider = context.read<AppProvider>();
    provider.updateSettings(_draft);
    
    final nextTime = _draft.getNextPlaybackTime();
    if (nextTime != null) {
      final timeStr = '${nextTime.hour.toString().padLeft(2, '0')}:${nextTime.minute.toString().padLeft(2, '0')}';
      final dateStr = '${nextTime.year}-${nextTime.month.toString().padLeft(2, '0')}-${nextTime.day.toString().padLeft(2, '0')}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم الجدولة بنجاح: سيتم التشغيل يوم $dateStr الساعة $timeStr', style: const TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppTheme.accentTeal,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إيقاف الجدولة التلقائية', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppTheme.textMuted,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
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
                    child: const Text('حفظ', style: TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
                    _buildEnableToggle(),
                    const SizedBox(height: 16),
                    _buildTimePicker(),
                    const SizedBox(height: 16),
                    _buildRepeatModeSelector(),
                    const SizedBox(height: 16),
                    if (_draft.repeatMode == RepeatMode.everyXDays) _buildIntervalSelector(),
                    if (_draft.repeatMode == RepeatMode.weekDays) _buildWeekDaySelector(),
                    const SizedBox(height: 24),
                    _buildPreview(),
                    const SizedBox(height: 24),
                    _buildTestButton(),
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

  Widget _buildEnableToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCard,
      child: Row(
        children: [
          const Icon(Icons.power_settings_new_rounded, color: AppTheme.gold),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('تفعيل الجدولة التلقائية', style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
          ),
          Switch(
            value: _draft.isEnabled,
            onChanged: (v) => setState(() => _draft = _draft.copyWith(isEnabled: v)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _draft.playbackTime,
          builder: (context, child) {
            return Theme(
              data: AppTheme.darkTheme.copyWith(
                timePickerTheme: TimePickerThemeData(
                  backgroundColor: AppTheme.cardBackground,
                  dialHandColor: AppTheme.gold,
                  hourMinuteColor: AppTheme.gold.withValues(alpha: 0.15),
                  hourMinuteTextColor: AppTheme.gold,
                  dayPeriodColor: AppTheme.gold.withValues(alpha: 0.15),
                  dayPeriodTextColor: AppTheme.gold,
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.glassCard,
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded, color: AppTheme.accentTeal),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('وقت التشغيل', style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
              ),
              child: Text(
                '${_draft.playbackTime.hour.toString().padLeft(2, '0')}:${_draft.playbackTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: AppTheme.gold, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatModeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.repeat_rounded, color: AppTheme.gold),
              SizedBox(width: 12),
              Text('نمط التكرار', style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          _buildModeOption(RepeatMode.daily, 'كل يوم', Icons.calendar_today_rounded),
          const SizedBox(height: 8),
          _buildModeOption(RepeatMode.everyXDays, 'كل عدد أيام معين', Icons.date_range_rounded),
          const SizedBox(height: 8),
          _buildModeOption(RepeatMode.weekDays, 'أيام معينة في الأسبوع', Icons.view_week_rounded),
        ],
      ),
    );
  }

  Widget _buildModeOption(RepeatMode mode, String label, IconData icon) {
    final isSelected = _draft.repeatMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _draft = _draft.copyWith(repeatMode: mode)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.gold.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppTheme.gold : AppTheme.cardBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? AppTheme.gold : AppTheme.textMuted),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: isSelected ? AppTheme.gold : AppTheme.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: AppTheme.gold, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCard,
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.looks_3_rounded, color: AppTheme.accentTeal),
              const SizedBox(width: 12),
              Text('كل ${_draft.intervalDays} أيام', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: _draft.intervalDays.toDouble(),
            min: 1, max: 14, divisions: 13,
            label: '${_draft.intervalDays} أيام',
            onChanged: (v) => setState(() => _draft = _draft.copyWith(intervalDays: v.toInt())),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('يوم', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              Text('${_draft.intervalDays}', style: const TextStyle(color: AppTheme.gold, fontSize: 16, fontWeight: FontWeight.bold)),
              const Text('١٤ يوم', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaySelector() {
    final dayNames = {1: 'الاثنين', 2: 'الثلاثاء', 3: 'الأربعاء', 4: 'الخميس', 5: 'الجمعة', 6: 'السبت', 7: 'الأحد'};
    final shortNames = {1: 'اث', 2: 'ثل', 3: 'أر', 4: 'خم', 5: 'جم', 6: 'سب', 7: 'أح'};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_view_week_rounded, color: AppTheme.accentTeal),
              SizedBox(width: 12),
              Text('اختر الأيام', style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
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
                    color: isSelected ? AppTheme.gold.withValues(alpha: 0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? AppTheme.gold : AppTheme.cardBorder),
                  ),
                  child: Text(shortNames[entry.key]!, style: TextStyle(color: isSelected ? AppTheme.gold : AppTheme.textMuted, fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal, fontSize: 13)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gold.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppTheme.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _draft.getScheduleDescription(),
              style: const TextStyle(color: AppTheme.gold, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentTeal,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () async {
        final now = DateTime.now();
        final testTime = now.add(const Duration(seconds: 10));
        
        // Save the real settings first
        await context.read<AppProvider>().updateSettings(_draft);
        
        // Force the alarm to 10 seconds from now
        await context.read<AppProvider>().testAlarmIn10Seconds();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم ضبط تنبيه تجريبي بعد 10 ثواني! انتظر...', style: TextStyle(fontFamily: 'Cairo')),
              backgroundColor: AppTheme.gold,
            ),
          );
        }
      },
      child: const Text('اختبار التنبيه (بعد 10 ثواني)', style: TextStyle(color: AppTheme.deepBackground, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
