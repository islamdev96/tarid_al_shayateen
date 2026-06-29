import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/library_audio.dart';
import '../models/adhan_sound.dart';
import '../providers/app_provider.dart';
import '../providers/prayer_times_provider.dart';
import '../providers/download_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/glassy_background.dart';

class AudioCategoryScreen extends StatefulWidget {
  final String categoryKey;
  final String categoryName;

  const AudioCategoryScreen({
    super.key,
    required this.categoryKey,
    required this.categoryName,
  });

  @override
  State<AudioCategoryScreen> createState() => _AudioCategoryScreenState();
}

class _AudioCategoryScreenState extends State<AudioCategoryScreen> {
  final AudioPlayer _previewPlayer = AudioPlayer();
  String? _previewingId;
  String? _selectedId;
  List<LibraryAudio> _downloadedItems = [];
  bool _isLoadingDownloads = false;

  @override
  void initState() {
    super.initState();
    _loadSelected();
    if (widget.categoryKey == 'downloads') {
      _loadDownloads();
    }
  }

  @override
  void dispose() {
    _previewPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadSelected() async {
    if (widget.categoryKey == 'adhan') {
      final prayerProvider = context.read<PrayerTimesProvider>();
      setState(() => _selectedId = prayerProvider.selectedAdhanId);
    } else {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() => _selectedId = prefs.getString('selected_${widget.categoryKey}_id'));
      }
    }
  }

  Future<void> _loadDownloads() async {
    if (!mounted) return;
    setState(() => _isLoadingDownloads = true);
    final provider = context.read<DownloadProvider>();
    final list = <LibraryAudio>[];
    for (final audio in LibraryAudio.allAudio) {
      final isCached = await provider.isAdhanCached(audio.id);
      if (isCached) {
        list.add(audio);
      }
    }
    if (mounted) {
      setState(() {
        _downloadedItems = list;
        _isLoadingDownloads = false;
      });
    }
  }

  Future<void> _togglePreview(LibraryAudio item) async {
    // Stop main background player if playing
    final appProvider = context.read<AppProvider>();
    if (appProvider.isPlaying) {
      await appProvider.stopPlayback();
    }

    if (_previewingId == item.id) {
      await _previewPlayer.stop();
      setState(() => _previewingId = null);
    } else {
      setState(() => _previewingId = item.id);
      try {
        await _previewPlayer.stop();
        
        if (!kIsWeb) {
          // If cached, play local file to save bandwidth
          final downloadProvider = context.read<DownloadProvider>();
          final isCached = await downloadProvider.isAdhanCached(item.id);
          if (isCached) {
            final dir = await getApplicationDocumentsDirectory();
            final localPath = '${dir.path}/adhan_${item.id}.mp3';
            await _previewPlayer.setFilePath(localPath);
          } else {
            await _previewPlayer.setUrl(item.url);
          }
        } else {
          // On web, always stream from URL
          await _previewPlayer.setUrl(item.url);
        }

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
            const SnackBar(
              content: Text(
                'تعذر تشغيل المعاينة - تحقق من الاتصال بالإنترنت',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _downloadItem(LibraryAudio item, DownloadProvider provider) async {
    try {
      final adhanSound = AdhanSound(id: item.id, nameAr: item.nameAr, url: item.url);
      await provider.downloadAdhan(adhanSound);
      if (widget.categoryKey == 'downloads') {
        _loadDownloads();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل تحميل الملف - تحقق من الاتصال بالإنترنت', style: TextStyle(fontFamily: 'Cairo')),
          ),
        );
      }
    }
  }

  Future<void> _selectItem(LibraryAudio item) async {
    final downloadProvider = context.read<DownloadProvider>();
    final isCached = await downloadProvider.isAdhanCached(item.id);

    if (!isCached) {
      // Auto download in background first
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('جاري تحميل "${item.nameAr}" لتعيينه كافتراضي...', style: const TextStyle(fontFamily: 'Cairo')),
          duration: const Duration(seconds: 2),
        ),
      );
      final adhanSound = AdhanSound(id: item.id, nameAr: item.nameAr, url: item.url);
      await downloadProvider.downloadAdhan(adhanSound);
    }

    if (widget.categoryKey == 'adhan') {
      final prayerProvider = context.read<PrayerTimesProvider>();
      await prayerProvider.updateSelectedAdhan(item.id);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_${widget.categoryKey}_id', item.id);
    }

    setState(() => _selectedId = item.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تعيين "${item.nameAr}" بنجاح 🔔', style: const TextStyle(fontFamily: 'Cairo')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final downloadProvider = context.watch<DownloadProvider>();

    final items = widget.categoryKey == 'downloads' 
        ? _downloadedItems 
        : LibraryAudio.getByCategory(widget.categoryKey);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.categoryName, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: GlassyBackground(
          child: _isLoadingDownloads
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
                  ? Center(
                      child: Text(
                        widget.categoryKey == 'downloads' 
                            ? 'لا توجد أصوات محملة حالياً'
                            : 'لا توجد أصوات في هذا القسم حالياً',
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isPreviewing = _previewingId == item.id;
                        final isSelected = _selectedId == item.id;
                        final cacheKey = downloadProvider.getAdhanCacheKey(item.id);
                        final isDownloading = downloadProvider.isDownloading(cacheKey);
                        final progress = downloadProvider.getProgress(cacheKey);

                        return FutureBuilder<bool>(
                          future: downloadProvider.isAdhanCached(item.id),
                          builder: (context, snapshot) {
                            final isCached = snapshot.data ?? false;

                            return GlassCard(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                leading: IconButton(
                                  icon: Icon(
                                    isPreviewing ? CupertinoIcons.stop_fill : CupertinoIcons.play_fill,
                                    color: theme.colorScheme.primary,
                                    size: 24,
                                  ),
                                  onPressed: () => _togglePreview(item),
                                ),
                                title: Text(
                                  item.nameAr,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: isSelected
                                    ? const Text(
                                        'مُعيّن كافتراضي',
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
                                    // Download Button / Status
                                    if (isDownloading)
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          value: progress,
                                          strokeWidth: 2,
                                          color: theme.colorScheme.primary,
                                        ),
                                      )
                                    else if (isCached)
                                      Icon(
                                        CupertinoIcons.checkmark_alt_circle_fill,
                                        color: theme.colorScheme.primary,
                                        size: 22,
                                      )
                                    else
                                      IconButton(
                                        icon: const Icon(CupertinoIcons.cloud_download, size: 22),
                                        color: theme.colorScheme.primary,
                                        onPressed: () => _downloadItem(item, downloadProvider),
                                      ),
                                    const SizedBox(width: 8),
                                    // Set as Default Button
                                    if (widget.categoryKey == 'adhan' || widget.categoryKey == 'iqamah')
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isSelected 
                                              ? Colors.green.withValues(alpha: 0.15)
                                              : theme.colorScheme.primary,
                                          foregroundColor: isSelected 
                                              ? Colors.green
                                              : theme.colorScheme.onPrimary,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: isSelected 
                                                ? const BorderSide(color: Colors.green, width: 0.5)
                                                : BorderSide.none,
                                          ),
                                        ),
                                        onPressed: () => _selectItem(item),
                                        child: Text(
                                          isSelected ? 'معيّن' : 'تعيين',
                                          style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
