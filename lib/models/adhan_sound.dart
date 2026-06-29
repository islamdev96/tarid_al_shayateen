class AdhanSound {
  final String id;
  final String nameAr;
  final String url;

  const AdhanSound({
    required this.id,
    required this.nameAr,
    required this.url,
  });

  static const List<AdhanSound> defaultAdhans = [
    AdhanSound(
      id: 'madinah',
      nameAr: 'أذان المسجد النبوي',
      url: 'https://www.islamcan.com/audio/adhan/azan1.mp3',
    ),
    AdhanSound(
      id: 'makkah',
      nameAr: 'أذان المسجد الحرام',
      url: 'https://www.islamcan.com/audio/adhan/azan2.mp3',
    ),
    AdhanSound(
      id: 'aqsa',
      nameAr: 'أذان المسجد الأقصى',
      url: 'https://www.islamcan.com/audio/adhan/azan3.mp3',
    ),
    AdhanSound(
      id: 'egypt',
      nameAr: 'أذان مصر',
      url: 'https://www.islamcan.com/audio/adhan/azan4.mp3',
    ),
    AdhanSound(
      id: 'mishary',
      nameAr: 'أذان مشاري العفاسي',
      url: 'https://www.islamcan.com/audio/adhan/azan5.mp3',
    ),
    AdhanSound(
      id: 'yusuf',
      nameAr: 'أذان يوسف إسلام',
      url: 'https://www.islamcan.com/audio/adhan/azan6.mp3',
    ),
  ];

  static AdhanSound findById(String id) {
    return defaultAdhans.firstWhere(
      (a) => a.id == id,
      orElse: () => defaultAdhans.first,
    );
  }
}
