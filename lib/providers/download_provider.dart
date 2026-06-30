import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/reciter.dart';
import '../models/surah.dart';
import '../models/adhan_sound.dart';

class DownloadProvider extends ChangeNotifier {
  final Map<String, double> _downloadProgresses = {};
  final Map<String, http.Client> _httpClients = {};
  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  double getProgress(String key) => _downloadProgresses[key] ?? 0.0;
  bool isDownloading(String key) => _downloadProgresses.containsKey(key);

  // Fallback for home screen Baqarah download status
  double get downloadProgress => _downloadProgresses.values.isNotEmpty ? _downloadProgresses.values.first : 0.0;
  bool get isDownloadingAny => _downloadProgresses.isNotEmpty;
  String get downloadingReciterName => ''; // Maintained for backward compatibility

  Future<void> autoDownloadOffline() async {
    final offlineReciter = Reciter.defaultReciters.first; // Al-Hussary
    final surahBaqarah = Surah.findByNumber(2);
    if (!await isSurahCached(surahBaqarah.number, offlineReciter.id)) {
      try {
        await downloadSurah(surahBaqarah, offlineReciter);
      } catch (e) {
        _errorMessage = 'فشل تحميل القارئ الافتراضي - تحقق من الإنترنت';
        notifyListeners();
      }
    }
  }

  // Backward compatibility wrapper
  Future<void> downloadReciter(Reciter reciter) async {
    final surahBaqarah = Surah.findByNumber(2);
    await downloadSurah(surahBaqarah, reciter);
  }

  Future<void> downloadSurah(Surah surah, Reciter reciter) async {
    if (kIsWeb) {
      _errorMessage = 'التحميل غير مدعوم على نسخة الويب';
      notifyListeners();
      return;
    }
    
    final key = getSurahCacheKey(surah.number, reciter.id);
    final url = '${reciter.serverUrl}${surah.formattedNumber}.mp3';
    final path = await getSurahCachedFilePath(surah.number, reciter.id);
    
    await _downloadAndCache(key, url, path);
  }

  Future<void> downloadAdhan(AdhanSound adhan) async {
    if (kIsWeb) return;
    final key = getAdhanCacheKey(adhan.id);
    final url = adhan.url;
    final path = await getAdhanCachedFilePath(adhan.id);
    
    await _downloadAndCache(key, url, path);
  }

  Future<void> _downloadAndCache(String key, String url, String path) async {
    final file = File(path);

    if (!await file.exists()) {
      if (isDownloading(key)) return;

      _downloadProgresses[key] = 0.0;
      _errorMessage = null;
      notifyListeners();

      final client = http.Client();
      _httpClients[key] = client;

      try {
        final request = http.Request('GET', Uri.parse(url));
        final response = await client.send(request);

        if (response.statusCode == 200) {
          final totalBytes = response.contentLength ?? 0;
          int receivedBytes = 0;
          final builder = BytesBuilder();
          double lastReportedProgress = 0.0;

          await for (final chunk in response.stream) {
            builder.add(chunk);
            receivedBytes += chunk.length;
            if (totalBytes > 0) {
              final progress = receivedBytes / totalBytes;
              if (progress - lastReportedProgress >= 0.01 || progress == 1.0) {
                _downloadProgresses[key] = progress;
                lastReportedProgress = progress;
                notifyListeners();
              }
            }
          }

          await file.writeAsBytes(builder.takeBytes());
        } else {
          throw Exception('فشل تحميل الملف الصوتي');
        }
      } catch (e) {
        // If aborted, don't show error unless needed
        if (_httpClients.containsKey(key)) {
          rethrow;
        }
      } finally {
        _httpClients[key]?.close();
        _httpClients.remove(key);
        _downloadProgresses.remove(key);
        notifyListeners();
      }
    }
  }

  void cancelDownload(String key) {
    if (_httpClients.containsKey(key)) {
      _httpClients[key]?.close();
      _httpClients.remove(key);
      _downloadProgresses.remove(key);
      notifyListeners();
    }
  }
  
  // Deprecated backward compatibility
  void cancelDownloadBackwardCompat() {
    if (_httpClients.isNotEmpty) {
      cancelDownload(_httpClients.keys.first);
    }
  }

  Future<bool> isReciterCached(String reciterId) async {
    return isSurahCached(2, reciterId);
  }

  String getSurahCacheKey(int surahNumber, String reciterId) => 'surah_${surahNumber}_$reciterId';
  String getAdhanCacheKey(String adhanId) => 'adhan_$adhanId';

  Future<bool> isSurahCached(int surahNumber, String reciterId) async {
    if (kIsWeb) return false;
    final path = await getSurahCachedFilePath(surahNumber, reciterId);
    return File(path).exists();
  }

  Future<bool> isAdhanCached(String adhanId) async {
    if (kIsWeb) return false;
    final path = await getAdhanCachedFilePath(adhanId);
    return File(path).exists();
  }

  Future<String> getSurahCachedFilePath(int surahNumber, String reciterId) async {
    if (kIsWeb) return '';
    final dir = await getApplicationDocumentsDirectory();
    // Maintain backward compatibility for Surah Baqarah cache path
    if (surahNumber == 2) {
      return '${dir.path}/surah_baqarah_$reciterId.mp3';
    }
    return '${dir.path}/surah_${surahNumber}_$reciterId.mp3';
  }

  Future<String> getAdhanCachedFilePath(String adhanId) async {
    if (kIsWeb) return '';
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/adhan_$adhanId.mp3';
  }
}
