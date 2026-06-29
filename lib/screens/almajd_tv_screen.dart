import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/glassy_background.dart';
import '../widgets/youtube_embed_stub.dart'
    if (dart.library.html) '../widgets/youtube_embed_web.dart'
    if (dart.library.io) '../widgets/youtube_embed_mobile.dart';

class AlmajdTvScreen extends StatelessWidget {
  const AlmajdTvScreen({super.key});

  static const String channelId = 'UCy787s06c8-H11pD17a9oEw';
  static const String fallbackUrl = 'https://www.youtube.com/channel/$channelId/live';

  Future<void> _launchExternal(BuildContext context) async {
    final uri = Uri.parse(fallbackUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.accentTeal : AppTheme.primaryGreen;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: GlassyBackground(
          child: SafeArea(
            child: Column(
              children: [
                // Top header bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios_rounded, color: primaryColor, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'قناة المجد للقرآن الكريم',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                          color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.share_up, size: 20),
                        color: primaryColor,
                        onPressed: () => _launchExternal(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Television Card with embedded player inside
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                      child: Column(
                        children: [
                          // Glow Live indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'البث التلفزيوني المباشر (داخل التطبيق)',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Embedded Player Frame
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.black,
                                border: Border.all(
                                  color: isDark ? AppTheme.cardBorder : AppTheme.lightCardBorder,
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: createYoutubeEmbed(channelId: channelId),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Info text
                          Text(
                            'تلاوات عطرة ومستمرة على مدار الساعة لخدمة كتاب الله بأصوات مشاهير القراء.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => _launchExternal(context),
                            icon: const Icon(CupertinoIcons.arrow_up_right_square, size: 16),
                            label: const Text(
                              'تشغيل في تطبيق يوتيوب الخارجي',
                              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
