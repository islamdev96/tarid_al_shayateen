import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/player_widget.dart';
import '../widgets/countdown_widget.dart';
import '../widgets/reciter_card.dart';
import '../widgets/download_progress_card.dart';
import '../widgets/schedule_card.dart';
import '../widgets/glass_card.dart';
import '../widgets/glassy_background.dart';

class BaqarahFortificationScreen extends StatelessWidget {
  const BaqarahFortificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: GlassyBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Custom Header
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: Icon(Icons.arrow_forward_ios_rounded, color: theme.colorScheme.primary, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'حصن البيت (سورة البقرة)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: 'Cairo',
                  ),
                ),
                centerTitle: true,
              ),

              SliverPadding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Bismillah Header
                    _buildBismillahHeader(),
                    const SizedBox(height: 16),

                    // Intro Card about Fortification
                    _buildIntroCard(theme, isDark),
                    const SizedBox(height: 20),

                    // Download Progress if downloading
                    if (provider.isDownloading) ...[
                      const DownloadProgressCard(),
                      const SizedBox(height: 16),
                    ],

                    // Error Card if any
                    if (provider.errorMessage != null) ...[
                      _buildErrorCard(provider, theme),
                      const SizedBox(height: 16),
                    ],

                    // Player Widget
                    const PlayerWidget(),
                    const SizedBox(height: 16),

                    // Countdown Widget (if scheduled and active)
                    if (provider.settings.isEnabled && provider.nextPlayback != null) ...[
                      const CountdownWidget(),
                      const SizedBox(height: 16),
                    ],

                    // Schedule Card (Toggle)
                    const ScheduleCard(),
                    const SizedBox(height: 16),

                    // Reciter Selector Widget
                    const ReciterCard(),
                    
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildBismillahHeader() {
    return const Text(
      'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 22,
        fontFamily: 'serif',
        color: AppTheme.gold,
        fontWeight: FontWeight.w400,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildIntroCard(ThemeData theme, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Icon(CupertinoIcons.shield_fill, color: theme.colorScheme.primary, size: 28),
          const SizedBox(height: 12),
          const Text(
            'قال رسول الله ﷺ: "إن الشيطان ينفر من البيت الذي تقرأ فيه سورة البقرة".',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 1.6,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قم بتفعيل جدولة التشغيل التلقائي ليشتغل صوت التحصين في بيتك بانتظام وبالتوقيت الذي تحدده.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
              height: 1.5,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(AppProvider provider, ThemeData theme) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      color: Colors.red.withValues(alpha: 0.12),
      border: Border.all(color: Colors.red.withValues(alpha: 0.4), width: 0.5),
      child: Row(
        children: [
          const Icon(CupertinoIcons.exclamationmark_circle, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              provider.errorMessage!,
              style: const TextStyle(
                color: Colors.red, 
                fontSize: 13,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
