import 'package:adhan/adhan.dart';
import '../models/prayer_time_settings.dart';

/// Class to hold calculated prayer times as DateTimes.
@pragma('vm:entry-point')
class CalculatedPrayerTimes {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  CalculatedPrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  /// Map of prayer times as Arabic names and formatted time strings.
  List<Map<String, dynamic>> toList() {
    return [
      {'id': 'fajr', 'name': 'الفجر', 'time': fajr},
      {'id': 'sunrise', 'name': 'الشروق', 'time': sunrise},
      {'id': 'dhuhr', 'name': 'الظهر', 'time': dhuhr},
      {'id': 'asr', 'name': 'العصر', 'time': asr},
      {'id': 'maghrib', 'name': 'المغرب', 'time': maghrib},
      {'id': 'isha', 'name': 'العشاء', 'time': isha},
    ];
  }
}

/// Service that computes prayer times using the adhan library.
@pragma('vm:entry-point')
class PrayerTimesService {
  /// Calculate prayer times for a given city and date.
  static CalculatedPrayerTimes calculate(CityConfig city, DateTime date) {
    final coordinates = Coordinates(city.latitude, city.longitude);
    
    // Egyptian General Authority of Survey parameters
    final params = CalculationMethod.egyptian.getParameters();
    params.madhab = Madhab.shafi;

    final dateComponents = DateComponents.from(date);

    final prayerTimes = PrayerTimes(
      coordinates,
      dateComponents,
      params,
    );

    // Get times in UTC and translate to local using device timezone offset
    // Since adhan library returns times in UTC, we convert to local DateTimes.
    return CalculatedPrayerTimes(
      fajr: prayerTimes.fajr.toLocal(),
      sunrise: prayerTimes.sunrise.toLocal(),
      dhuhr: prayerTimes.dhuhr.toLocal(),
      asr: prayerTimes.asr.toLocal(),
      maghrib: prayerTimes.maghrib.toLocal(),
      isha: prayerTimes.isha.toLocal(),
    );
  }

  /// Finds the next upcoming prayer time from now and returns its name and time.
  static Map<String, dynamic>? getNextPrayer(CityConfig city) {
    final now = DateTime.now();
    final todayTimes = calculate(city, now);
    
    final list = todayTimes.toList();
    for (final item in list) {
      if ((item['time'] as DateTime).isAfter(now)) {
        return item;
      }
    }

    // If all of today's prayers have passed, the next prayer is Fajr tomorrow
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowTimes = calculate(city, tomorrow);
    return {
      'id': 'fajr',
      'name': 'الفجر',
      'time': tomorrowTimes.fajr,
      'isTomorrow': true,
    };
  }
}
