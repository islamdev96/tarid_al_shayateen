import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/reciter.dart';

class DownloadProvider extends ChangeNotifier {
  double _downloadProgress = 0.0;
  bool _isDownloading = false;
  String _downloadingReciterName = '';
  bool _downloadCancelled = false;
  http.Client? _httpClient;
  String? _errorMessage;

  double get downloadProgress => _downloadProgress;
  bool get isDownloading => _isDownloading;
  String get downloadingReciterName => _downloadingReciterName;
  String? get errorMessage => _errorMessage;

  Future<void> autoDownloadOffline() async {
    final offlineReciter = Reciter.defaultReciters.first; // Al-Hussary
    final path = await _getCachedFilePath(offlineReciter.id);
    if (!await File(path).exists()) {
      try {
        await _downloadAndCache(offlineReciter);
      } catch (e) {
        _errorMessage = 'فشل تحميل القارئ الافتراضي - تحقق من الإنترنت';
        _isDownloading = false;
        notifyListeners();
      }
    }
  }

  Future<void> downloadReciter(Reciter reciter) async {
    if (kIsWeb) {
      _errorMessage = 'التحميل غير مدعوم على نسخة الويب';
      notifyListeners();
      return;
    }
    await _downloadAndCache(reciter);
  }

  Future<void> _downloadAndCache(Reciter reciter) async {
    final path = await _getCachedFilePath(reciter.id);
    final file = File(path);

    if (!await file.exists()) {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadingReciterName = reciter.nameAr;
      _downloadCancelled = false;
      _errorMessage = null;
      notifyListeners();

      _httpClient = http.Client();
      try {
        final request = http.Request('GET', Uri.parse(reciter.surahBaqarahUrl));
        final response = await _httpClient!.send(request);

        if (response.statusCode == 200) {
          final totalBytes = response.contentLength ?? 0;
          int receivedBytes = 0;
          final builder = BytesBuilder();
          double lastReportedProgress = 0.0;

          await for (final chunk in response.stream) {
            if (_downloadCancelled) {
              throw Exception('تم إلغاء التحميل');
            }
            builder.add(chunk);
            receivedBytes += chunk.length;
            if (totalBytes > 0) {
              final progress = receivedBytes / totalBytes;
              if (progress - lastReportedProgress >= 0.01 || progress == 1.0) {
                _downloadProgress = progress;
                lastReportedProgress = progress;
                notifyListeners();
              }
            }
          }

          if (!_downloadCancelled) {
            await file.writeAsBytes(builder.takeBytes());
          }
        } else {
          throw Exception('فشل تحميل الملف الصوتي');
        }
      } catch (e) {
        if (_downloadCancelled) {
          throw Exception('تم إلغاء التحميل');
        }
        rethrow;
      } finally {
        _httpClient?.close();
        _httpClient = null;
        _isDownloading = false;
        _downloadProgress = _downloadCancelled ? 0.0 : 1.0;
        _downloadingReciterName = '';
        notifyListeners();
      }
    }
  }

  void cancelDownload() {
    _downloadCancelled = true;
    _httpClient?.close();
    _httpClient = null;
    _isDownloading = false;
    _downloadProgress = 0.0;
    _downloadingReciterName = '';
    notifyListeners();
  }

  Future<bool> isReciterCached(String reciterId) async {
    final path = await _getCachedFilePath(reciterId);
    return File(path).exists();
  }

  Future<String> _getCachedFilePath(String reciterId) async {
    if (kIsWeb) return '';
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/surah_baqarah_$reciterId.mp3';
  }
}
