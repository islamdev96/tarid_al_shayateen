import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../constants/api_urls.dart';
import '../constants/app_strings.dart';

/// Provider responsible for downloading, caching, and serving Quranic Surah texts.
class SurahTextProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  final Map<int, List<String>> _cachedSurahTexts = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<String>? getSurahText(int surahNumber) => _cachedSurahTexts[surahNumber];

  /// Get the text lines of a surah, checking local cache first, then API.
  Future<List<String>?> loadSurahText(int surahNumber) async {
    if (_cachedSurahTexts.containsKey(surahNumber)) {
      return _cachedSurahTexts[surahNumber];
    }

    if (!kIsWeb) {
      final path = await _getSurahTextFilePath(surahNumber);
      final file = File(path);

      if (await file.exists()) {
        try {
          final content = await file.readAsString();
          final verses = content.split('\n');
          _cachedSurahTexts[surahNumber] = verses;
          return verses;
        } catch (e) {
          debugPrint('Error reading cached Surah text: $e');
        }
      }
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('${ApiUrls.quranTextApiBase}/$surahNumber'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final ayahsJson = data['data']['ayahs'] as List;
        final verses = ayahsJson.map((a) => a['text'] as String).toList();

        // Strip Bismillah from the first verse if it's there
        if (verses.isNotEmpty && surahNumber != 1 && surahNumber != 9) {
          const bismillah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
          if (verses[0].startsWith(bismillah)) {
            verses[0] = verses[0].substring(bismillah.length).trim();
          }
        }

        // Save to local cache file
        if (!kIsWeb) {
          final path = await _getSurahTextFilePath(surahNumber);
          await File(path).writeAsString(verses.join('\n'));
        }
        _cachedSurahTexts[surahNumber] = verses;
        return verses;
      } else {
        throw Exception('فشل الاتصال بالخادم. رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = AppStrings.surahLoadError;
      debugPrint('Error loading Surah text: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> _getSurahTextFilePath(int surahNumber) async {
    if (kIsWeb) return '';
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/surah_text_$surahNumber.txt';
  }
}
