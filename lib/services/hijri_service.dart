class HijriDate {
  final int year;
  final int month;
  final int day;
  final String monthNameAr;

  HijriDate({
    required this.year,
    required this.month,
    required this.day,
    required this.monthNameAr,
  });

  static const List<String> _monthsAr = [
    'المحرم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة'
  ];

  static const List<String> _daysAr = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد'
  ];

  factory HijriDate.fromDate(DateTime date) {
    int year = date.year;
    int month = date.month;
    int day = date.day;

    if (month < 3) {
      year -= 1;
      month += 12;
    }

    double a = (year / 100).floorToDouble();
    double b = 2 - a + (a / 4).floorToDouble();
    
    double jd = (365.25 * (year + 4716)).floorToDouble() + 
         (30.6001 * (month + 1)).floorToDouble() + 
         day + b - 1524.5;
         
    int jdInt = jd.round();
    
    // Kuwaiti algorithm calculations
    int l = jdInt - 1948440 + 10632;
    int n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    int j = (((10985 - l) / 5316).floor()) * (((50 * l) / 17719).floor()) + 
            (((l) / 5670).floor()) * (((43 * l) / 15238).floor());
    l = l - (((30 - j) / 15).floor()) * (((17719 * j) / 50).floor()) - 
            (((j) / 16).floor()) * (((15238 * j) / 43).floor()) + 29;
    int m = ((24 * l) / 709).floor();
    int d = l - ((709 * m) / 24).floor();
    int y = 30 * n + j - 30;

    int monthIndex = m - 1;
    if (monthIndex < 0) monthIndex = 0;
    if (monthIndex > 11) monthIndex = 11;

    return HijriDate(
      year: y,
      month: monthIndex + 1,
      day: d,
      monthNameAr: _monthsAr[monthIndex],
    );
  }

  static String getWeekdayAr(DateTime date) {
    return _daysAr[date.weekday - 1];
  }

  static const List<String> _gregorianMonthsAr = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر'
  ];

  static String getGregorianMonthAr(DateTime date) {
    return _gregorianMonthsAr[date.month - 1];
  }
}
