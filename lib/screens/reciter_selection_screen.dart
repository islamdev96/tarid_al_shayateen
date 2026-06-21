import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/reciter.dart';
import '../providers/app_provider.dart';

class ReciterSelectionScreen extends StatefulWidget {
  const ReciterSelectionScreen({super.key});

  @override
  State<ReciterSelectionScreen> createState() => _ReciterSelectionScreenState();
}

class _ReciterSelectionScreenState extends State<ReciterSelectionScreen> {
  final AudioPlayer _previewPlayer = AudioPlayer();
  String? _previewingId;
  String? _downloadingId;
  final Map<String, bool> _cachedMap = {};

  @override
  void initState() {
    super.initState();
    _loadCachedStatus();
  }

  Future<void> _loadCachedStatus() async {
    final provider = context.read<AppProvider>();
    for (final r in Reciter.defaultReciters) {
      final cached = await provider.isReciterCached(r.id);
      if (mounted) {
        setState(() => _cachedMap[r.id] = cached);
      }
    }
  }

  @override
  void dispose() {
    _previewPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePreview(Reciter reciter) async {
    if (_previewingId == reciter.id) {
      await _previewPlayer.stop();
      setState(() => _previewingId = null);
    } else {
      setState(() => _previewingId = reciter.id);
      try {
        await _previewPlayer.setUrl(reciter.surahBaqarahUrl);
        await _previewPlayer.setClip(
          start: Duration.zero,
          end: const Duration(seconds: 30),
        );
        await _previewPlayer.play();
        _previewPlayer.processingStateStream.listen((state) {
          if (state == ProcessingState.completed && mounted) {
            setState(() => _previewingId = null);
          }
        });
      } catch (_) {
        if (mounted) {
          setState(() => _previewingId = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر تشغيل المعاينة - تحقق من الإنترنت', style: TextStyle(fontFamily: 'Cairo'))),
          );
        }
      }
    }
  }

  Future<void> _downloadReciter(Reciter reciter, AppProvider provider) async {
    setState(() => _downloadingId = reciter.id);
    try {
      await provider.downloadReciter(reciter);
      if (mounted) {
        setState(() {
          _downloadingId = null;
          _cachedMap[reciter.id] = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تحميل ${reciter.nameAr} بنجاح ✅', style: const TextStyle(fontFamily: 'Cairo'))),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _downloadingId = null);
        final isCancelled = e.toString().contains('إلغاء');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCancelled ? 'تم إلغاء التحميل' : 'فشل التحميل - تحقق من الإنترنت',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
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
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(context)),
        child: SafeArea(
          child: Consumer<AppProvider>(
            builder: (context, provider, _) {
              final selectedId = provider.settings.selectedReciterId;
              final reciters = Reciter.defaultReciters;

              return CustomScrollView(
                slivers: [
                  const SliverAppBar(
                    floating: true,
                    backgroundColor: Colors.transparent,
                    title: Text('اختيار القارئ'),
                  ),

                  // Download progress
                  if (provider.isDownloading)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.glassCard(context),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.secondary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'جاري تحميل القارئ (${provider.downloadingReciterName})',
                                      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
                                    ),
                                  ),
                                  // Cancel button
                                  GestureDetector(
                                    onTap: () => provider.cancelDownload(),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: AppTheme.errorRed.withValues(alpha: 0.15),
                                      ),
                                      child: const Text('إلغاء', style: TextStyle(color: AppTheme.errorRed, fontSize: 12, fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: provider.downloadProgress,
                                  backgroundColor: isDark ? AppTheme.cardBorder : AppTheme.lightCardBorder,
                                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${(provider.downloadProgress * 100).toInt()}%',
                                style: TextStyle(color: theme.colorScheme.secondary, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  _buildReciterList(context, reciters, selectedId, provider, theme),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildReciterList(BuildContext ctx, List<Reciter> reciters, String selectedId, AppProvider provider, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final r = reciters[index];
            final isSelected = r.id == selectedId;
            final isPreviewing = _previewingId == r.id;
            final isCached = _cachedMap[r.id] ?? r.isOffline;
            final isDownloadingThis = _downloadingId == r.id;
            final isAnyDownloading = provider.isDownloading;

            final borderCol = isPreviewing 
                ? theme.colorScheme.secondary 
                : (isSelected 
                    ? theme.colorScheme.primary 
                    : (isDark ? AppTheme.cardBorder : AppTheme.lightCardBorder));

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  _previewPlayer.stop();
                  provider.selectReciter(r.id);
                  Navigator.pop(ctx);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? theme.colorScheme.primary.withValues(alpha: 0.1) 
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: borderCol,
                      width: isSelected || isPreviewing ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected 
                              ? theme.colorScheme.primary.withValues(alpha: 0.2) 
                              : (isDark ? AppTheme.cardBorder : AppTheme.lightCardBorder).withValues(alpha: 0.3),
                        ),
                        child: Icon(Icons.person_rounded, color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodySmall?.color, size: 22),
                      ),
                      const SizedBox(width: 12),

                      // Name & status
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.nameAr,
                              style: TextStyle(
                                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  isCached ? Icons.phone_android_rounded : Icons.wifi_rounded,
                                  size: 13,
                                  color: isCached ? AppTheme.successGreen : theme.colorScheme.secondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isCached ? 'محفوظ أوفلاين ✓' : 'أونلاين',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isCached ? AppTheme.successGreen : theme.colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                            if (isPreviewing)
                              Row(
                                children: [
                                  SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.secondary)),
                                  const SizedBox(width: 6),
                                  Text('جاري المعاينة...', style: TextStyle(fontSize: 11, color: theme.colorScheme.secondary)),
                                ],
                              ),
                          ],
                        ),
                      ),

                      // Preview button
                      GestureDetector(
                        onTap: () => _togglePreview(r),
                        child: Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPreviewing 
                                ? theme.colorScheme.secondary.withValues(alpha: 0.2) 
                                : (isDark ? AppTheme.cardBorder : AppTheme.lightCardBorder).withValues(alpha: 0.3),
                          ),
                          child: Icon(
                            isPreviewing ? Icons.stop_rounded : Icons.play_arrow_rounded,
                            color: isPreviewing ? theme.colorScheme.secondary : theme.textTheme.bodySmall?.color,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Download button (if not cached)
                      if (!isCached)
                        GestureDetector(
                          onTap: () {
                            if (isDownloadingThis) {
                              provider.cancelDownload();
                            } else if (!isAnyDownloading) {
                              _downloadReciter(r, provider);
                            }
                          },
                          child: Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDownloadingThis
                                  ? AppTheme.errorRed.withValues(alpha: 0.15)
                                  : (isAnyDownloading
                                      ? theme.textTheme.bodySmall?.color?.withValues(alpha: 0.15)
                                      : theme.colorScheme.primary.withValues(alpha: 0.15)),
                            ),
                            child: isDownloadingThis
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        value: provider.downloadProgress,
                                        strokeWidth: 2,
                                        color: AppTheme.errorRed.withValues(alpha: 0.5),
                                      ),
                                      const Icon(Icons.close_rounded, color: AppTheme.errorRed, size: 16),
                                    ],
                                  )
                                : Icon(Icons.download_rounded, 
                                    color: isAnyDownloading ? theme.textTheme.bodySmall?.color : theme.colorScheme.primary, 
                                    size: 18),
                          ),
                        ),
                      if (!isCached) const SizedBox(width: 6),

                      // Selection indicator
                      isSelected
                          ? Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppTheme.goldGradient,
                              ),
                              child: const Icon(Icons.check_rounded, color: AppTheme.deepBackground, size: 18),
                            )
                          : Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? AppTheme.cardBorder : AppTheme.lightCardBorder,
                                  width: 2,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
          childCount: reciters.length,
        ),
      ),
    );
  }
}
