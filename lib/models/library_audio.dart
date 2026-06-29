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
      id: 'abdulbasit',
      category: 'adhan',
      nameAr: 'أذان عبد الباسط عبد الصمد',
      url: 'https://www.islamcan.com/audio/adhan/azan7.mp3',
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
      url: 'https://www.islamcan.com/audio/adhan/azan8.mp3',
    ),
    LibraryAudio(
      id: 'iqamah_madinah',
      category: 'iqamah',
      nameAr: 'إقامة الصلاة - الحرم المدني',
      url: 'https://www.islamcan.com/audio/adhan/azan5.mp3',
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
