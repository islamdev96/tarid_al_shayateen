import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quran_verse.dart';
import '../services/quran_api_service.dart';

import 'package:just_audio/just_audio.dart';

class MushafProvider with ChangeNotifier {
  final QuranApiService _apiService = QuranApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  int _currentPage = 1;
  int get currentPage => _currentPage;

  bool _isLoadingPage = false;
  bool get isLoadingPage => _isLoadingPage;

  List<QuranVerse> _currentVerses = [];
  List<QuranVerse> get currentVerses => _currentVerses;

  int? _bookmarkedPage;
  int? get bookmarkedPage => _bookmarkedPage;

  String? _selectedVerseKey;
  String? get selectedVerseKey => _selectedVerseKey;

  bool _isPlayingVerse = false;
  bool get isPlayingVerse => _isPlayingVerse;

  String? _playingVerseKey;
  String? get playingVerseKey => _playingVerseKey;

  MushafProvider() {
    _loadBookmark();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // Repeat the verse
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.play();
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> playVerse(String verseKey) async {
    _playingVerseKey = verseKey;
    _isPlayingVerse = true;
    notifyListeners();

    try {
      final url = await _apiService.getVerseAudioUrl(verseKey);
      if (url != null) {
        await _audioPlayer.setUrl(url);
        await _audioPlayer.play();
      } else {
        stopVerse();
      }
    } catch (e) {
      debugPrint('Error playing verse: $e');
      stopVerse();
    }
  }

  void stopVerse() {
    _audioPlayer.stop();
    _isPlayingVerse = false;
    _playingVerseKey = null;
    notifyListeners();
  }

  Future<void> _loadBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    _bookmarkedPage = prefs.getInt('mushaf_bookmark_page_v2');
    if (_bookmarkedPage != null) {
      _currentPage = _bookmarkedPage!;
    }
    await fetchPage(_currentPage);
  }

  Future<void> saveBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mushaf_bookmark_page_v2', _currentPage);
    _bookmarkedPage = _currentPage;
    notifyListeners();
  }

  Future<void> changePage(int page) async {
    if (page < 1 || page > 604 || page == _currentPage) return;
    _currentPage = page;
    notifyListeners(); // Update UI for page change instantly (shows loading)
    await fetchPage(page);
  }

  Future<void> fetchPage(int pageNumber) async {
    _isLoadingPage = true;
    notifyListeners();

    try {
      _currentVerses = await _apiService.getPage(pageNumber);
      
      // Pre-fetch next page silently
      if (pageNumber < 604) {
        _apiService.getPage(pageNumber + 1);
      }
    } catch (e) {
      debugPrint('Error fetching page $pageNumber: $e');
      _currentVerses = [];
    } finally {
      _isLoadingPage = false;
      notifyListeners();
    }
  }

  void selectVerse(String? verseKey) {
    _selectedVerseKey = verseKey;
    notifyListeners();
  }

  // --- Theme / Reading Settings (Dark Mode / Colors) ---
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  double _fontSizeMultiplier = 1.0;
  double get fontSizeMultiplier => _fontSizeMultiplier;

  void toggleDarkMode(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }

  void updateFontSize(double multiplier) {
    _fontSizeMultiplier = multiplier;
    notifyListeners();
  }
}
