import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/player_widget.dart';
import '../widgets/countdown_widget.dart';
import '../widgets/reciter_card.dart';
import '../widgets/download_progress_card.dart';
import '../widgets/schedule_card.dart';

class BaqarahFortificationScreen extends StatelessWidget {
  const BaqarahFortificationScreen({super.key});

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
              // Custom Header
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_rounded, color: theme.colorScheme.primary),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Bismillah Header
                    _buildBismillahHeader(),
                    const SizedBox(height: 16),

                    // Intro Card about Fortification
                    _buildIntroCard(theme),
                    const SizedBox(height: 20),

                    // Download Progress if downloading
                    if (provider.isDownloading) ...[
                      const DownloadProgressCard(),
                      const SizedBox(height: 16),
                    ],

                    // Error Card if any
                    if (provider.errorMessage != null) ...[
                      _buildErrorCard(provider),
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
    );
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

  Widget _buildIntroCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(Icons.shield_rounded, color: theme.colorScheme.primary, size: 28),
          const SizedBox(height: 8),
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
          const SizedBox(height: 4),
          Text(
            'قم بتفعيل جدولة التشغيل التلقائي ليشتغل صوت التحصين في بيتك بانتظام وبالتوقيت الذي تحدده.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodyMedium?.color,
              height: 1.5,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
