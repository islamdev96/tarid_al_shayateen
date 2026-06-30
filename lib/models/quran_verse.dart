class QuranWord {
  final int id;
  final int position;
  final String textUthmani;
  final String? audioUrl;
  final String charTypeName; // e.g. "word", "end"

  QuranWord({
    required this.id,
    required this.position,
    required this.textUthmani,
    this.audioUrl,
    required this.charTypeName,
  });

  factory QuranWord.fromJson(Map<String, dynamic> json) {
    return QuranWord(
      id: json['id'],
      position: json['position'],
      textUthmani: json['text_uthmani'] ?? '',
      audioUrl: json['audio_url'],
      charTypeName: json['char_type_name'] ?? 'word',
    );
  }
}

class QuranVerse {
  final int id;
  final String verseKey; // e.g. "1:1"
  final String textUthmani;
  final List<QuranWord> words;

  QuranVerse({
    required this.id,
    required this.verseKey,
    required this.textUthmani,
    required this.words,
  });

  factory QuranVerse.fromJson(Map<String, dynamic> json) {
    var wordsList = json['words'] as List? ?? [];
    List<QuranWord> parsedWords = wordsList.map((w) => QuranWord.fromJson(w)).toList();

    return QuranVerse(
      id: json['id'],
      verseKey: json['verse_key'],
      textUthmani: json['text_uthmani'] ?? '',
      words: parsedWords,
    );
  }
}

class TafseerData {
  final int id;
  final String verseKey;
  final String text;

  TafseerData({
    required this.id,
    required this.verseKey,
    required this.text,
  });

  factory TafseerData.fromJson(Map<String, dynamic> json) {
    return TafseerData(
      id: json['id'] ?? 0,
      verseKey: json['verse_key'] ?? '',
      text: json['text'] ?? '',
    );
  }
}
