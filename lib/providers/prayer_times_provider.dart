import 'package:flutter/material.dart';
import '../models/prayer_time_settings.dart';
import '../services/settings_service.dart';
import '../services/scheduler_service.dart';

class PrayerTimesProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

  CityConfig _selectedCity = CityConfig.defaultCities.first;
  final Map<String, bool> _prayerNotifications = {};
  String _selectedAdhanId = 'madinah';

  CityConfig get selectedCity {
    if (_settingsService.locationMode == 'automatic') {
      return CityConfig(
        id: 'gps',
        nameAr: 'الموقع التلقائي (GPS)',
        nameEn: 'Automatic GPS',
        latitude: _settingsService.gpsLatitude,
        longitude: _settingsService.gpsLongitude,
      );
    }
    return _selectedCity;
  }
  Map<String, bool> get prayerNotifications => _prayerNotifications;
  String get selectedAdhanId => _selectedAdhanId;

  Future<void> init() async {
    await _settingsService.init();
    
    final cityId = _settingsService.selectedCityId;
    _selectedCity = CityConfig.findById(cityId);
    
    for (final prayerId in ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha']) {
      _prayerNotifications[prayerId] = _settingsService.getPrayerNotification(prayerId);
    }
    
    _selectedAdhanId = _settingsService.selectedAdhanId;

    _schedulePrayerAlarms();
    notifyListeners();
  }

  Future<void> updateSelectedCity(String cityId) async {
    _selectedCity = CityConfig.findById(cityId);
    await _settingsService.setSelectedCityId(cityId);
    await _settingsService.setLocationMode('manual');
    _schedulePrayerAlarms();
    notifyListeners();
  }

  Future<void> togglePrayerNotification(String prayerId) async {
    final currentVal = _prayerNotifications[prayerId] ?? true;
    _prayerNotifications[prayerId] = !currentVal;
    await _settingsService.setPrayerNotification(prayerId, !currentVal);
    _schedulePrayerAlarms();
    notifyListeners();
  }

  Future<void> updateSelectedAdhan(String adhanId) async {
    _selectedAdhanId = adhanId;
    await _settingsService.setSelectedAdhanId(adhanId);
    notifyListeners();
  }

  void _schedulePrayerAlarms() {
    SchedulerService.scheduleNextPrayer(_selectedCity);
  }
}
