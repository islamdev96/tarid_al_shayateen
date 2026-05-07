/// Represents a Quran reciter with their audio server details.
class Reciter {
  final String id;
  final String nameAr;
  final String serverUrl;
  final bool isOffline;

  const Reciter({
    required this.id,
    required this.nameAr,
    required this.serverUrl,
    this.isOffline = false,
  });

  /// Gets the URL for Surah Al-Baqarah (002) from this reciter's server.
  String get surahBaqarahUrl => '${serverUrl}002.mp3';

  /// Predefined list of popular reciters.
  static const List<Reciter> defaultReciters = [
    // ⭐ القارئ الافتراضي - أوفلاين
    Reciter(
      id: 'husr',
      nameAr: 'محمود خليل الحصري',
      serverUrl: 'https://server13.mp3quran.net/husr/',
      isOffline: true,
    ),
    // القراء أونلاين
    Reciter(
      id: 'bna',
      nameAr: 'محمود علي البنا',
      serverUrl: 'https://server8.mp3quran.net/bna/',
    ),
    Reciter(
      id: 'minsh',
      nameAr: 'محمد صديق المنشاوي',
      serverUrl: 'https://server10.mp3quran.net/minsh/',
    ),
    Reciter(
      id: 'tblawi',
      nameAr: 'محمد الطبلاوي',
      serverUrl: 'https://server12.mp3quran.net/tblawi/',
    ),
    Reciter(
      id: 'basit',
      nameAr: 'عبدالباسط عبدالصمد',
      serverUrl: 'https://server7.mp3quran.net/basit/',
    ),
    Reciter(
      id: 'shur',
      nameAr: 'سعود الشريم',
      serverUrl: 'https://server7.mp3quran.net/shur/',
    ),
    Reciter(
      id: 'maher',
      nameAr: 'ماهر المعيقلي',
      serverUrl: 'https://server12.mp3quran.net/maher/',
    ),
    Reciter(
      id: 'ajm',
      nameAr: 'أحمد بن علي العجمي',
      serverUrl: 'https://server10.mp3quran.net/ajm/',
    ),
    Reciter(
      id: 'jleel',
      nameAr: 'خالد الجليل',
      serverUrl: 'https://server10.mp3quran.net/jleel/',
    ),
    Reciter(
      id: 's_gmd',
      nameAr: 'سعد الغامدي',
      serverUrl: 'https://server7.mp3quran.net/s_gmd/',
    ),
    Reciter(
      id: 'shatri',
      nameAr: 'أبو بكر الشاطري',
      serverUrl: 'https://server11.mp3quran.net/shatri/',
    ),
    Reciter(
      id: 'mustafa',
      nameAr: 'مصطفى إسماعيل',
      serverUrl: 'https://server8.mp3quran.net/mustafa/',
    ),
    Reciter(
      id: 'ayyub',
      nameAr: 'محمد أيوب',
      serverUrl: 'https://server8.mp3quran.net/ayyub/',
    ),
  ];

  /// Find a reciter by ID from the default list.
  static Reciter findById(String id) {
    return defaultReciters.firstWhere(
      (r) => r.id == id,
      orElse: () => defaultReciters.first,
    );
  }
}
