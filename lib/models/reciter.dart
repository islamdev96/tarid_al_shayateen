import '../constants/api_urls.dart';

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
      serverUrl: ApiUrls.husaryServer,
      isOffline: true,
    ),
    // القراء أونلاين
    Reciter(
      id: 'bna',
      nameAr: 'محمود علي البنا',
      serverUrl: ApiUrls.banaServer,
    ),
    Reciter(
      id: 'minsh',
      nameAr: 'محمد صديق المنشاوي',
      serverUrl: ApiUrls.minshawiServer,
    ),
    Reciter(
      id: 'tblawi',
      nameAr: 'محمد الطبلاوي',
      serverUrl: ApiUrls.tablawiServer,
    ),
    Reciter(
      id: 'basit',
      nameAr: 'عبدالباسط عبدالصمد',
      serverUrl: ApiUrls.abdulbasitServer,
    ),
    Reciter(
      id: 'shur',
      nameAr: 'سعود الشريم',
      serverUrl: ApiUrls.shuraimServer,
    ),
    Reciter(
      id: 'maher',
      nameAr: 'ماهر المعيقلي',
      serverUrl: ApiUrls.maherServer,
    ),
    Reciter(
      id: 'ajm',
      nameAr: 'أحمد بن علي العجمي',
      serverUrl: ApiUrls.ajmiServer,
    ),
    Reciter(
      id: 'jleel',
      nameAr: 'خالد الجليل',
      serverUrl: ApiUrls.jaleelServer,
    ),
    Reciter(
      id: 's_gmd',
      nameAr: 'سعد الغامدي',
      serverUrl: ApiUrls.ghamdiServer,
    ),
    Reciter(
      id: 'shatri',
      nameAr: 'أبو بكر الشاطري',
      serverUrl: ApiUrls.shatriServer,
    ),
    Reciter(
      id: 'mustafa',
      nameAr: 'مصطفى إسماعيل',
      serverUrl: ApiUrls.mustafaServer,
    ),
    Reciter(
      id: 'ayyub',
      nameAr: 'محمد أيوب',
      serverUrl: ApiUrls.ayyoubServer,
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
