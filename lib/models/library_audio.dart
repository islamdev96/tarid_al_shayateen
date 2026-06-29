class LibraryAudio {
  final String id;
  final String category; // 'adhan', 'iqamah', 'azkar', 'dua', 'ramadan', 'eid'
  final String nameAr;
  final String url;

  const LibraryAudio({
    required this.id,
    required this.category,
    required this.nameAr,
    required this.url,
  });

  static const List<LibraryAudio> allAudio = [
    // 1. أذان (Adhan)
    LibraryAudio(
      id: 'madinah',
      category: 'adhan',
      nameAr: 'أذان المسجد النبوي',
      url: 'https://www.islamcan.com/audio/adhan/azan1.mp3',
    ),
    LibraryAudio(
      id: 'makkah',
      category: 'adhan',
      nameAr: 'أذان المسجد الحرام',
      url: 'https://www.islamcan.com/audio/adhan/azan2.mp3',
    ),
    LibraryAudio(
      id: 'aqsa',
      category: 'adhan',
      nameAr: 'أذان المسجد الأقصى',
      url: 'https://www.islamcan.com/audio/adhan/azan3.mp3',
    ),
    LibraryAudio(
      id: 'egypt',
      category: 'adhan',
      nameAr: 'أذان مصر',
      url: 'https://www.islamcan.com/audio/adhan/azan4.mp3',
    ),
    LibraryAudio(
      id: 'mishary',
      category: 'adhan',
      nameAr: 'أذان مشاري العفاسي',
      url: 'https://www.islamcan.com/audio/adhan/azan5.mp3',
    ),
    LibraryAudio(
      id: 'yusuf',
      category: 'adhan',
      nameAr: 'أذان يوسف إسلام',
      url: 'https://www.islamcan.com/audio/adhan/azan6.mp3',
    ),

    // 2. إقامة (Iqamah)
    LibraryAudio(
      id: 'iqamah_makkah',
      category: 'iqamah',
      nameAr: 'إقامة الصلاة - الحرم المكي',
      url: 'https://www.islamcan.com/audio/adhan/azan2.mp3',
    ),
    LibraryAudio(
      id: 'iqamah_madinah',
      category: 'iqamah',
      nameAr: 'إقامة الصلاة - الحرم المدني',
      url: 'https://www.islamcan.com/audio/adhan/azan1.mp3',
    ),

    // 3. أذكار (Azkar)
    LibraryAudio(
      id: 'azkar_morning',
      category: 'azkar',
      nameAr: 'أذكار الصباح - مشاري العفاسي',
      url: 'https://server12.mp3quran.net/afs/001.mp3',
    ),
    LibraryAudio(
      id: 'azkar_evening',
      category: 'azkar',
      nameAr: 'أذكار المساء - مشاري العفاسي',
      url: 'https://server12.mp3quran.net/afs/002.mp3',
    ),

    // 4. أدعية (Dua)
    LibraryAudio(
      id: 'dua_sudais',
      category: 'dua',
      nameAr: 'دعاء القنوت - السديس',
      url: 'https://download.quranicaudio.com/duas/sudais_dua.mp3',
    ),
    LibraryAudio(
      id: 'dua_shuraim',
      category: 'dua',
      nameAr: 'دعاء القنوت - الشريم',
      url: 'https://download.quranicaudio.com/duas/dua_by_sheikh_ash-shuraim.mp3',
    ),

    // 5. رمضانيات (Ramadaniyat)
    LibraryAudio(
      id: 'ramadan_tarawih',
      category: 'ramadan',
      nameAr: 'تكبيرات التراويح - الحرم المكي',
      url: 'https://download.quranicaudio.com/quran/yaser_ad-dussary/001.mp3',
    ),
    LibraryAudio(
      id: 'ramadan_ibtehal',
      category: 'ramadan',
      nameAr: 'ابتهالات رمضانية بصوت النقشبندي',
      url: 'https://download.quranicaudio.com/quran/yaser_ad-dussary/002.mp3',
    ),

    // 6. العيد (Eid)
    LibraryAudio(
      id: 'eid_takbeerat',
      category: 'eid',
      nameAr: 'تكبيرات العيد - الحرم المكي',
      url: 'https://download.quranicaudio.com/duas/takbeer.mp3',
    ),
    LibraryAudio(
      id: 'eid_takbeerat_group',
      category: 'eid',
      nameAr: 'تكبيرات العيد - جماعية',
      url: 'https://download.quranicaudio.com/duas/takbeer.mp3',
    ),
  ];

  static List<LibraryAudio> getByCategory(String category) {
    return allAudio.where((a) => a.category == category).toList();
  }

  static LibraryAudio findById(String id) {
    return allAudio.firstWhere(
      (a) => a.id == id,
      orElse: () => allAudio.first,
    );
  }
}
