import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/quran_verse.dart';

class QuranApiService {
  static const String _baseUrl = 'https://api.quran.com/api/v4';
  
  // Cache pages to avoid redundant network calls
  final Map<int, List<QuranVerse>> _pagesCache = {};
  final Map<String, TafseerData> _tafseerCache = {};

  /// Fetch verses for a specific Mushaf page
  Future<List<QuranVerse>> getPage(int pageNumber) async {
    if (_pagesCache.containsKey(pageNumber)) {
      return _pagesCache[pageNumber]!;
    }

    final url = Uri.parse('$_baseUrl/verses/by_page/$pageNumber?language=ar&words=true&word_fields=text_uthmani,audio_url&fields=text_uthmani');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final versesList = data['verses'] as List? ?? [];
        
        final verses = versesList.map((v) => QuranVerse.fromJson(v)).toList();
        _pagesCache[pageNumber] = verses;
        return verses;
      } else {
        throw Exception('Failed to load page $pageNumber: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while loading page $pageNumber: $e');
    }
  }

  /// Fetch Tafseer (Mokhtasar - 164) for a specific verse
  Future<TafseerData> getTafseer(String verseKey) async {
    if (_tafseerCache.containsKey(verseKey)) {
      return _tafseerCache[verseKey]!;
    }

    // 16 is Tafsir Al-Muyassar (Arabic)
    final url = Uri.parse('$_baseUrl/tafsirs/16/by_ayah/$verseKey');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tafseerJson = data['tafsir'];
        
        if (tafseerJson != null) {
          final tafseer = TafseerData(
            id: tafseerJson['id'] ?? 0,
            verseKey: verseKey,
            text: tafseerJson['text'] ?? 'تفسير غير متوفر',
          );
          _tafseerCache[verseKey] = tafseer;
          return tafseer;
        } else {
          return TafseerData(id: 0, verseKey: verseKey, text: 'لا يوجد تفسير لهذه الآية.');
        }
      } else {
        throw Exception('Failed to load tafseer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while loading tafseer: $e');
    }
  }

  /// Search verses by query text
  Future<List<Map<String, dynamic>>> searchVerses(String query) async {
    final url = Uri.parse('$_baseUrl/search?q=$query&size=20&page=1&language=ar');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['search']['results'] as List? ?? [];
        return results.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Search failed');
      }
    } catch (e) {
      debugPrint('Search error: $e');
      return [];
    }
  }

  /// Get Audio URL for a specific verse (Reciter 7: Mishari Al-Afasy)
  Future<String?> getVerseAudioUrl(String verseKey) async {
    final url = Uri.parse('$_baseUrl/recitations/7/by_ayah/$verseKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final audioFiles = data['audio_files'] as List?;
        if (audioFiles != null && audioFiles.isNotEmpty) {
          String audioUrl = audioFiles[0]['url'];
          if (audioUrl.startsWith('//')) {
            audioUrl = 'https:$audioUrl';
          } else if (!audioUrl.startsWith('http')) {
            audioUrl = 'https://audio.quran.com/$audioUrl';
          }
          return audioUrl;
        }
      }
    } catch (e) {
      debugPrint('Error fetching audio url: $e');
    }
    return null;
  }
}
