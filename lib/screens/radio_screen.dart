import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/app_provider.dart';

class RadioStation {
  final String nameAr;
  final String nameEn;
  final String url;

  const RadioStation({
    required this.nameAr,
    required this.nameEn,
    required this.url,
  });
}

const List<RadioStation> defaultStations = [
  RadioStation(
    nameAr: 'إذاعة القرآن الكريم - القاهرة',
    nameEn: 'Quran Radio Cairo',
    url: 'http://stream.radiojar.com/8s5u5tpdtwzuv',
  ),
  RadioStation(
    nameAr: 'إذاعة القرآن الكريم - مكة المكرمة',
    nameEn: 'Quran Radio Makkah',
    url: 'http://live.mp3quran.net:9722/;',
  ),
  RadioStation(
    nameAr: 'إذاعة القرآن الكريم - الشارقة',
    nameEn: 'Sharjah Quran Radio',
    url: 'http://live.mp3quran.net:9888/;',
  ),
  RadioStation(
    nameAr: 'إذاعة الرقية الشرعية',
    nameEn: 'Al-Ruqyah Al-Shariah Radio',
    url: 'http://live.mp3quran.net:9702/;',
  ),
  RadioStation(
    nameAr: 'إذاعة تفسير القرآن الكريم',
    nameEn: 'Quran Tafsir Radio',
    url: 'http://live.mp3quran.net:9718/;',
  ),
];

const List<RadioStation> reciterStations = [
  RadioStation(
    nameAr: 'إذاعة الشيخ عبد الباسط عبد الصمد',
    nameEn: 'Sheikh Abdul Basit Radio',
    url: 'http://live.mp3quran.net:9984/;',
  ),
  RadioStation(
    nameAr: 'إذاعة الشيخ محمود خليل الحصري',
    nameEn: 'Sheikh Al-Hussary Radio',
    url: 'http://live.mp3quran.net:9968/;',
  ),
  RadioStation(
    nameAr: 'إذاعة الشيخ محمد صديق المنشاوي',
    nameEn: 'Sheikh Al-Minshawi Radio',
    url: 'http://live.mp3quran.net:9958/;',
  ),
  RadioStation(
    nameAr: 'إذاعة الشيخ ماهر المعيقلي',
    nameEn: 'Sheikh Maher Al-Muaiqly Radio',
    url: 'http://live.mp3quran.net:9948/;',
  ),
  RadioStation(
    nameAr: 'إذاعة الشيخ مشاري بن راشد العفاسي',
    nameEn: 'Sheikh Al-Afasy Radio',
    url: 'http://live.mp3quran.net:9938/;',
  ),
];

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  int _activeTab = 0; // 0 = Radio, 1 = Reciters
  bool _isMuted = false;
  double _preMuteVolume = 1.0;

  static const Color orangeAccent = Color(0xFFFF7F32); // Premium orange accent from the screenshot
  static const Color darkCardBg = Color(0xFF0C1612);   // Very dark background matching the card design

  void _toggleMute(AppProvider provider) {
    if (_isMuted) {
      provider.setVolume(_preMuteVolume);
      setState(() {
        _isMuted = false;
      });
    } else {
      _preMuteVolume = provider.volume > 0 ? provider.volume : 1.0;
      provider.setVolume(0.0);
      setState(() {
        _isMuted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final stations = _activeTab == 0 ? defaultStations : reciterStations;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(context)),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar with Back Button
              _buildTopBar(theme),

              // Logo & App Name Header
              _buildHeaderLogo(),

              // Tabs Selector (Radio & Reciters)
              _buildTabsSelector(theme),
              const SizedBox(height: 20),

              // Stations List View
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  itemCount: stations.length,
                  itemBuilder: (context, index) {
                    final station = stations[index];
                    final isCurrent = provider.isLiveStream && provider.activeAudioTitle == station.nameAr;
                    final isPlaying = isCurrent && provider.isPlaying;

                    return _buildStationCard(context, station, isCurrent, isPlaying, provider, theme);
                  },
                ),
              ),

              // Global Premium Player Panel (Fixed at Bottom when Radio plays)
              if (provider.isLiveStream)
                _buildPlayerPanel(provider, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: theme.colorScheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'إذاعة القرآن الكريم',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          ),
          const SizedBox(width: 48), // Spacer to balance back button
        ],
      ),
    );
  }

  Widget _buildHeaderLogo() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: orangeAccent.withValues(alpha: 0.1),
            border: Border.all(color: orangeAccent.withValues(alpha: 0.3), width: 1.5),
          ),
          child: const Icon(
            Icons.radio_rounded,
            color: orangeAccent,
            size: 32,
          ),
        ),
        const Text(
          'سَكينة راديو',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: orangeAccent,
            fontFamily: 'Cairo',
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTabsSelector(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14241D) : const Color(0xFFE6EDE9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              label: 'Radio',
              icon: Icons.radio_rounded,
              isActive: _activeTab == 0,
              onTap: () => setState(() => _activeTab = 0),
            ),
          ),
          Expanded(
            child: _buildTabButton(
              label: 'Reciters',
              icon: Icons.person_rounded,
              isActive: _activeTab == 1,
              onTap: () => setState(() => _activeTab = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? orangeAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationCard(
    BuildContext context,
    RadioStation station,
    bool isCurrent,
    bool isPlaying,
    AppProvider provider,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final cardBorderColor = isCurrent ? orangeAccent : (isDark ? AppTheme.cardBorder : AppTheme.lightCardBorder);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cardBorderColor,
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? orangeAccent.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCurrent
                ? orangeAccent.withValues(alpha: 0.15)
                : (isDark ? AppTheme.cardBorder.withValues(alpha: 0.2) : AppTheme.lightCardBorder.withValues(alpha: 0.3)),
          ),
          child: Icon(
            Icons.radio_rounded,
            color: isCurrent ? orangeAccent : (isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary),
            size: 20,
          ),
        ),
        title: Text(
          station.nameAr,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            fontFamily: 'Cairo',
          ),
        ),
        subtitle: Text(
          station.nameEn,
          style: TextStyle(
            color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
            fontSize: 12,
          ),
        ),
        trailing: GestureDetector(
          onTap: () {
            if (isCurrent) {
              provider.togglePlayPause();
            } else {
              provider.playRadio(station.url, station.nameAr);
            }
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPlaying ? Colors.red.withValues(alpha: 0.15) : orangeAccent,
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: isPlaying ? Colors.red : Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerPanel(AppProvider provider, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: orangeAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: orangeAccent.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Station Name & Live Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Mute Button
              IconButton(
                icon: Icon(
                  _isMuted || provider.volume == 0.0
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  color: orangeAccent,
                ),
                onPressed: () => _toggleMute(provider),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      provider.activeAudioTitle,
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const Text(
                      'البث المباشر للإذاعة',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Live Pulse indicator
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Close/Stop Button
              IconButton(
                icon: const Icon(Icons.stop_rounded, color: Colors.red),
                iconSize: 28,
                onPressed: () => provider.stopRadio(),
              ),
              const SizedBox(width: 24),

              // Play / Pause Circle Button
              GestureDetector(
                onTap: () => provider.togglePlayPause(),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: orangeAccent,
                    boxShadow: [
                      BoxShadow(
                        color: orangeAccent.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    provider.isLoading
                        ? Icons.hourglass_empty_rounded
                        : provider.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 52), // Symmetry space
            ],
          ),
        ],
      ),
    );
  }
}
