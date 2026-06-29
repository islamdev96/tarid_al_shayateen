class AndroidAlarmManager {
  static Future<bool> initialize() async => false;
  static Future<bool> oneShotAt(DateTime time, int id, Function callback, {bool exact = false, bool wakeup = false, bool alarmClock = false, bool allowWhileIdle = false, bool rescheduleOnReboot = false}) async => false;
  static Future<bool> cancel(int id) async => false;
}
