/// Representation of prayer times calculation settings.
class PrayerTimeSettings {
  final String selectedCityId;
  final Map<String, bool> notificationSettings; // Key: prayer name (fajr, dhuhr...), Value: enabled/disabled

  const PrayerTimeSettings({
    this.selectedCityId = 'cairo',
    this.notificationSettings = const {
      'fajr': true,
      'sunrise': false,
      'dhuhr': true,
      'asr': true,
      'maghrib': true,
      'isha': true,
    },
  });

  PrayerTimeSettings copyWith({
    String? selectedCityId,
    Map<String, bool>? notificationSettings,
  }) {
    return PrayerTimeSettings(
      selectedCityId: selectedCityId ?? this.selectedCityId,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }
}

/// Represents a city configuration with its geographic coordinates.
@pragma('vm:entry-point')
class CityConfig {
  final String id;
  final String nameAr;
  final String nameEn;
  final double latitude;
  final double longitude;

  const CityConfig({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.latitude,
    required this.longitude,
  });

  /// Predefined list of popular Egyptian cities and their coordinates.
  static const List<CityConfig> defaultCities = [
    CityConfig(id: 'cairo', nameAr: 'القاهرة', nameEn: 'Cairo', latitude: 30.0444, longitude: 31.2357),
    CityConfig(id: 'alexandria', nameAr: 'الإسكندرية', nameEn: 'Alexandria', latitude: 31.2001, longitude: 29.9187),
    CityConfig(id: 'giza', nameAr: 'الجيزة', nameEn: 'Giza', latitude: 30.0131, longitude: 31.2089),
    CityConfig(id: 'mansoura', nameAr: 'المنصورة', nameEn: 'Mansoura', latitude: 31.0409, longitude: 31.3785),
    CityConfig(id: 'tanta', nameAr: 'طنطا', nameEn: 'Tanta', latitude: 30.7865, longitude: 31.0004),
    CityConfig(id: 'assiut', nameAr: 'أسيوط', nameEn: 'Assiut', latitude: 27.1810, longitude: 31.1837),
    CityConfig(id: 'aswan', nameAr: 'أسوان', nameEn: 'Aswan', latitude: 24.0889, longitude: 32.8998),
    CityConfig(id: 'luxor', nameAr: 'الأقصر', nameEn: 'Luxor', latitude: 25.6872, longitude: 32.6396),
    CityConfig(id: 'portsaid', nameAr: 'بورسعيد', nameEn: 'Port Said', latitude: 31.2653, longitude: 32.3019),
    CityConfig(id: 'suez', nameAr: 'السويس', nameEn: 'Suez', latitude: 29.9668, longitude: 32.5498),
  ];

  static CityConfig findById(String id) {
    return defaultCities.firstWhere(
      (c) => c.id == id,
      orElse: () => defaultCities.first,
    );
  }
}
