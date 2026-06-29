import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class QuranProvider extends ChangeNotifier {
  bool _isLoadingSurahText = false;
  String? _errorMessage;
  final Map<int, List<String>> _cachedSurahTexts = {};

  bool get isLoadingSurahText => _isLoadingSurahText;
  String? get errorMessage => _errorMessage;

  List<String>? getSurahText(int number) => _cachedSurahTexts[number];

  Future<List<String>?> loadSurahText(int surahNumber) async {
    if (_cachedSurahTexts.containsKey(surahNumber)) {
      return _cachedSurahTexts[surahNumber];
    }

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

    _isLoadingSurahText = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/$surahNumber'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final ayahsJson = data['data']['ayahs'] as List;
        final verses = ayahsJson.map((a) => a['text'] as String).toList();

        if (verses.isNotEmpty && surahNumber != 1 && surahNumber != 9) {
          const bismillah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
          if (verses[0].startsWith(bismillah)) {
            verses[0] = verses[0].substring(bismillah.length).trim();
          }
        }

        await file.writeAsString(verses.join('\n'));
        _cachedSurahTexts[surahNumber] = verses;
        return verses;
      } else {
        throw Exception('فشل الاتصال بالخادم. رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'فشل تحميل نص السورة: تأكد من اتصالك بالإنترنت';
      debugPrint('Error loading Surah text: $e');
      return null;
    } finally {
      _isLoadingSurahText = false;
      notifyListeners();
    }
  }

  Future<String> _getSurahTextFilePath(int surahNumber) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/surah_text_$surahNumber.txt';
  }
}
