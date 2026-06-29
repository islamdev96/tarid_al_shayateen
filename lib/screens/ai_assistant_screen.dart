import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../app_theme.dart';
import '../ui/glass/glass_container.dart';
import '../ui/glass/glass_card.dart';
import '../ui/glass/glass_sheets.dart';
import '../widgets/glassy_background.dart';

/// Representation of a single message in the chat
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

/// Representation of a Cognitive Mode / Personality preset
class CognitiveMode {
  final String title;
  final String description;
  final IconData icon;
  final LinearGradient gradient;
  final Color accentColor;

  const CognitiveMode({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.accentColor,
  });
}

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  int _selectedModeIndex = 0;
  double _responseDepth = 65.0; // Slider value out of 100
  
  // Custom toggles for modal settings
  bool _voiceEnabled = true;
  bool _citationsEnabled = true;
  double _creativityScore = 0.7;

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'مرحباً بك! أنا رفيقك الروحي الذكي المدعوم بالذكاء الاصطناعي. كيف يمكنني مساعدتك اليوم في رحلتك الإيمانية أو إجابة استفساراتك؟',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatMessage(
      text: 'أبحث عن أذكار تزيد من الطمأنينة والهدوء النفسي وتساعدني على التركيز والخشوع.',
      isUser: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    ChatMessage(
      text: 'عليك بذكر "ألا بذكر الله تطمئن القلوب". وكذلك الإكثار من "لا حول ولا قوة إلا بالله" والاستغفار بقلب حاضر.\n\nمن الأذكار المأثورة المهدئة:\n«اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ».\n\nهل تود أن نستعرض معاً بعض الأدعية والآيات القرآنية المعينة على السكينة؟',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

  final List<CognitiveMode> _modes = const [
    CognitiveMode(
      title: 'الرفيق الروحي',
      description: 'إجابات إيمانية، روحانية، ومحفزة للسكينة والتدبر.',
      icon: CupertinoIcons.sparkles,
      gradient: LinearGradient(
        colors: [Color(0xFFE4C39B), Color(0xFFD4A976), Color(0xFF59331F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentColor: AppTheme.gold,
    ),
    CognitiveMode(
      title: 'الباحث الفقهي',
      description: 'منهج علمي رصين يعتمد على الأدلة الصحيحة والتفاسير المعتمدة.',
      icon: CupertinoIcons.book_fill,
      gradient: LinearGradient(
        colors: [Color(0xFF0A84FF), Color(0xFF007AFF), Color(0xFF5E5CE6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentColor: Color(0xFF0A84FF),
    ),
    CognitiveMode(
      title: 'المستشار النفسي',
      description: 'دعم نفسي وتوجيه إرشادي يربط بين الصحة النفسية والإيمان.',
      icon: CupertinoIcons.heart_circle_fill,
      gradient: LinearGradient(
        colors: [Color(0xFFBF5AF2), Color(0xFFAF52DE), Color(0xFFFF2D55)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentColor: Color(0xFFBF5AF2),
    ),
    CognitiveMode(
      title: 'المذكر البلاغي',
      description: 'حكمة أدبية مستوحاة من لغة القرآن وبلاغة السنة النبوية.',
      icon: CupertinoIcons.waveform,
      gradient: LinearGradient(
        colors: [Color(0xFF30D158), Color(0xFF34C759), Color(0xFF0D4A2B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accentColor: Color(0xFF30D158),
    ),
  ];

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
    });

    _scrollToBottom();

    // Trigger a simulated AI premium response after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      
      String aiResponse = '';
      final mode = _modes[_selectedModeIndex];
      
      if (mode.title == 'الرفيق الروحي') {
        aiResponse = 'سأبحث لك عن أعمق المعاني الروحية في ذلك. تذكر دائماً أن القرب من الله عز وجل يبدأ بالنية الصادقة والورد اليومي. كيف تحب أن نبدأ رحلتنا اليوم؟';
      } else if (mode.title == 'الباحث الفقهي') {
        aiResponse = 'وفقاً للمصادر المعتمدة والتفاسير الصحيحة، فإن هذا الجانب يتأطر بالعديد من الأدلة الفقهية. سأفصل لك القول بوضوح وأمانة علمية.';
      } else if (mode.title == 'المستشار النفسي') {
        aiResponse = 'من الناحية النفسية والوجدانية، ترتبط الراحة ارتباطاً وثيقاً بسلامة القلب وتفريغ الشحنات السلبية بالدعاء. إليك بعض الخطوات الإرشادية العملية.';
      } else {
        aiResponse = 'ببلاغة الكلام وجميل التعبير، تضيء الكلمات عتمة الروح وتأخذنا الآيات في بحار الإعجاز اللغوي الفسيح.';
      }

      setState(() {
        _messages.add(ChatMessage(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    showGlassDialog(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.delete_solid,
            color: AppTheme.errorRed,
            size: 36,
          ),
          const SizedBox(height: 16),
          const Text(
            'حذف المحادثة؟',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'سيتم حذف كافة الرسائل الحالية من ذاكرة الشاشة نهائياً.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorRed.withValues(alpha: 0.8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _messages.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'تأكيد الحذف',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showAdvancedSettings() {
    showGlassBottomSheet(
      context,
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'المعايير المتقدمة للذكاء الاصطناعي',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 24),

              // Setting 1: Voice Response
              _buildModalToggle(
                title: 'الإجابات الصوتية الذكية',
                subtitle: 'توليد قراءة صوتية للإجابات الطويلة بنبرة هادئة.',
                value: _voiceEnabled,
                onChanged: (val) {
                  setModalState(() => _voiceEnabled = val);
                  setState(() => _voiceEnabled = val);
                },
              ),
              const Divider(color: Colors.white12, height: 24),

              // Setting 2: Citations
              _buildModalToggle(
                title: 'توثيق الأدلة والمراجع',
                subtitle: 'إظهار الآيات والأحاديث النبوية وتفاسيرها بشكل مفصل.',
                value: _citationsEnabled,
                onChanged: (val) {
                  setModalState(() => _citationsEnabled = val);
                  setState(() => _citationsEnabled = val);
                },
              ),
              const Divider(color: Colors.white12, height: 24),

              // Setting 3: Creativity Scale
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'مستوى التوسع والربط الفكري',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        '${(_creativityScore * 100).toInt()}%',
                        style: const TextStyle(
                          color: AppTheme.gold,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'التحكم في نسبة التدبر والاسترسال اللغوي في الإجابة.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppTheme.gold,
                      inactiveTrackColor: Colors.white10,
                      thumbColor: Colors.white,
                      overlayColor: AppTheme.gold.withValues(alpha: 0.2),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    ),
                    child: Slider(
                      value: _creativityScore,
                      onChanged: (val) {
                        setModalState(() => _creativityScore = val);
                        setState(() => _creativityScore = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Done Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Colors.white24, width: 0.5),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'حفظ وتطبيق',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModalToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
        CupertinoSwitch(
          value: value,
          activeTrackColor: AppTheme.gold,
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeMode = _modes[_selectedModeIndex];

    return Scaffold(
      body: GlassyBackground(
        child: Stack(
          children: [
            // Ambient glowing reflections helper
            Positioned(
              top: 180,
              left: 40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeMode.accentColor.withValues(alpha: 0.12),
                ),
              ),
            ),

            // Scrollable Content & Main Chat Layout
            Column(
              children: [
                // Top Custom Glass Navigation Bar
                _buildGlassAppBar(context),

                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // 1. Apple-style Settings Control Panel
                            _buildControlPanel(context),
                            const SizedBox(height: 20),

                            // 2. Divider indicating Chat Context
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white10, width: 0.5),
                                ),
                                child: Text(
                                  'جلسة حوارية نشطة • وضع ${activeMode.title}',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 3. Message List
                            ..._messages.map((msg) => _buildMessageBubble(msg)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. Floating Pill Input Field Bar
                _buildInputBar(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassAppBar(BuildContext context) {
    final activeMode = _modes[_selectedModeIndex];
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            border: const Border(
              bottom: BorderSide(color: Colors.white12, width: 0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Close Button (glass circle)
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: const Icon(CupertinoIcons.xmark, color: Colors.white, size: 18),
                ),
              ),

              // Title
              Column(
                children: [
                  const Text(
                    'الرفيق الذكي AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Cairo',
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    activeMode.title,
                    style: TextStyle(
                      color: activeMode.accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),

              // Right Share/Export Button (glass circle)
              GestureDetector(
                onTap: () {
                  // Simulate sharing
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم نسخ رابط الجلسة الصوتية بنجاح', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Cairo')),
                      backgroundColor: Colors.indigoAccent,
                    ),
                  );
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: const Icon(CupertinoIcons.share, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context) {
    final activeMode = _modes[_selectedModeIndex];

    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row: Control Panel Title
          Row(
            children: [
              Icon(CupertinoIcons.slider_horizontal_3, color: activeMode.accentColor, size: 16),
              const SizedBox(width: 6),
              const Text(
                'التحكم في معايير الذكاء الاصطناعي',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Horizontal list of Cognitive Presets (Circular glowing avatars)
          SizedBox(
            height: 96,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _modes.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final mode = _modes[index];
                final isSelected = index == _selectedModeIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedModeIndex = index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Column(
                      children: [
                        // Selected Double Border Container
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: mode.gradient,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 0.8,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: mode.accentColor.withValues(alpha: 0.45),
                                    blurRadius: 14,
                                    spreadRadius: 1,
                                  ),
                              ],
                            ),
                            child: Icon(
                              mode.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          mode.title,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white54,
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),

          // Short Description of selected cognitive mode
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              activeMode.description,
              key: ValueKey<int>(_selectedModeIndex),
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontFamily: 'Cairo',
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // iOS-style Custom Depth Slider (matches the uploaded image)
          Row(
            children: [
              const Icon(CupertinoIcons.sparkles, color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                    overlayColor: Colors.white.withValues(alpha: 0.15),
                    trackHeight: 3.5,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                  ),
                  child: Slider(
                    value: _responseDepth,
                    min: 0.0,
                    max: 100.0,
                    onChanged: (val) {
                      setState(() {
                        _responseDepth = val;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _responseDepth.toInt().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Row: Transparent Glass Pill Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _showAdvancedSettings,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white24, width: 0.8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.settings_solid, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'معايير متقدمة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _clearChat,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white24, width: 0.8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.trash, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'مسح المحادثة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final activeMode = _modes[_selectedModeIndex];
    final isUser = msg.isUser;
    final bubbleRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.78,
          child: GlassContainer(
            borderRadius: bubbleRadius,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            opacity: isUser ? 0.08 : 0.15,
            color: isUser ? Colors.white : activeMode.accentColor,
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  msg.text,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 13.5,
                    fontFamily: 'Cairo',
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white30,
                        fontSize: 9,
                      ),
                    ),
                    if (!isUser) ...[
                      const SizedBox(width: 6),
                      Icon(
                        CupertinoIcons.sparkles,
                        color: activeMode.accentColor.withValues(alpha: 0.6),
                        size: 10,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    final activeMode = _modes[_selectedModeIndex];

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            border: const Border(
              top: BorderSide(color: Colors.white12, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              // Left Mic Button
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('الاستماع مستمر...', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Cairo')),
                      backgroundColor: Colors.orangeAccent,
                    ),
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: const Icon(
                    CupertinoIcons.mic_fill,
                    color: Colors.white70,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Chat Input Pill Card
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: Colors.white.withValues(alpha: 0.08),
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Cairo',
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'اسأل الرفيق الذكي...',
                            hintStyle: TextStyle(
                              color: Colors.white38,
                              fontFamily: 'Cairo',
                              fontSize: 12.5,
                            ),
                            hintTextDirection: TextDirection.rtl,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Right Send Button (glowing sparkles)
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: activeMode.gradient,
                    boxShadow: [
                      BoxShadow(
                        color: activeMode.accentColor.withValues(alpha: 0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.paperplane_fill,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
