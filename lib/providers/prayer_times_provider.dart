import 'package:flutter/material.dart';
import '../models/prayer_time_settings.dart';
import '../services/settings_service.dart';
import '../services/scheduler_service.dart';

class PrayerTimesProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

  CityConfig _selectedCity = CityConfig.defaultCities.first;
  final Map<String, bool> _prayerNotifications = {};

  CityConfig get selectedCity => _selectedCity;
  Map<String, bool> get prayerNotifications => _prayerNotifications;

  Future<void> init() async {
    await _settingsService.init();
    
    final cityId = _settingsService.selectedCityId;
    _selectedCity = CityConfig.findById(cityId);
    
    for (final prayerId in ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha']) {
      _prayerNotifications[prayerId] = _settingsService.getPrayerNotification(prayerId);
    }

    _schedulePrayerAlarms();
    notifyListeners();
  }

  Future<void> updateSelectedCity(String cityId) async {
    _selectedCity = CityConfig.findById(cityId);
    await _settingsService.setSelectedCityId(cityId);
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

  void _schedulePrayerAlarms() {
    SchedulerService.scheduleNextPrayer(_selectedCity);
  }
}
