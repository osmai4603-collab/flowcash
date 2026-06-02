abstract class AppDateFormatter {
  static const List<int> _days = [384, 32, 1];
  static const List<int> _times = [3600, 60, 1];

  static const Map<int, String> weekNameInSymbolArabic = {
    1: 'ن',
    2: 'ث',
    3: 'ر',
    4: 'خ',
    5: 'ج',
    6: 'س',
    7: 'ح',
  };

  static const Map<int, String> weekNameInFullArabic = {
    1: 'الإثنين',
    2: 'الثلاثاء',
    3: 'الأربعاء',
    4: 'الخميس',
    5: 'الجمعة',
    6: 'السبت',
    7: 'الأحد',
  };

  static const Map<int, String> yearMonthInArabic = {
    1: 'يناير',
    2: 'فبراير',
    3: 'مارس',
    4: 'ابريل',
    5: 'مايو',
    6: 'يونيو',
    7: 'يوليو',
    8: 'أغسطس',
    9: 'سبتمبر',
    10: 'أكتوبر',
    11: 'نوفمبر',
    12: 'ديسمبر'
  };

  static String getCurrentDate({String split = '/'}) {
    return toDateString(DateTime.now(), split: split);
  }

  static String getCurrentTime() {
    return toTimeString(DateTime.now());
  }

  static String toDateString(DateTime date, {String split = '/'}) {
    return '${'${date.day}'.padLeft(2, '0')}$split${'${date.month}'.padLeft(2, '0')}$split${'${date.year}'.padLeft(4, '0')}';
  }

  static String toTimeString(DateTime time) {
    final isPM = time.hour >= 12;
    return '${(isPM ? '${time.hour > 12 ? time.hour % 12 : 12}' : '${time.hour == 0 ? 12 : time.hour}').padLeft(2, '0')}:'
        '${'${time.minute}'.padLeft(2, '0')}:'
        '${'${time.second}'.padLeft(2, '0')} '
        '${isPM ? 'PM' : 'AM'}';
  }

  static DateTime convertTimeStringToDateTime(String time) {
    final tim = time.split(' ').first;
    final digits = tim.split(':').map((e) => int.parse(e)).toList();
    final isPM = time.endsWith('PM');
    return DateTime(1, 1, 1, isPM ? (digits[0] > 12 ? digits[0] + 12 : 12) : (digits[0] == 12 ? 0 : digits[0]), digits[1], digits[2]);
  }

  static DateTime toDateTime({String? date, String? time}) {
    if (date == null && time == null) return DateTime.now();
    DateTime? dateTime;
    if (date != null) {
      final list = date.split('/');
      dateTime = DateTime(list.length > 2 ? int.parse(list[2]) : 0, list.length > 1 ? int.parse(list[1]) : 0, int.parse(list[0]));
    }
    if (time != null) {
      final digits = time.split(' ').first.split(':').map((e) => int.parse(e)).toList();
      final isPM = time.endsWith('PM');
      dateTime = DateTime(dateTime?.year ?? 0, dateTime?.month ?? 1, dateTime?.day ?? 1,
          isPM ? (digits[0] > 12 ? digits[0] + 12 : 12) : (digits[0] == 12 ? 0 : digits[0]), digits[1], digits[2]);
    }
    return dateTime!;
  }

  static int convertDateStringToSeconds(String date) {
    return toDays(date) * 24 * 60 * 60;
  }

  static String convertDateTimeToString(DateTime dt) {
    return '${toDateString(dt)}-${toTimeString(dt)}';
  }

  static String getDayName(String date) {
    final dateSel = toDateTime(date: date);
    return weekNameInFullArabic[dateSel.weekday]!;
  }

  static String getMonthName(String date) {
    final dateSel = toDateTime(date: date);
    return yearMonthInArabic[dateSel.month]!;
  }

  static String convertDateTimeToStringDaysSeconds(DateTime date, {String split = '_'}) {
    return toDays(toDateString(date)).toString().padLeft(5, '0') +
        split +
        toSeconds(toTimeString(date)).toString().padLeft(5, '0');
  }

  static String getDateYear(int countDays) {
    return (countDays ~/ 384).toString();
  }

  static String getDateMonthYear(int countDays) {
    return '${'${((countDays % 384) ~/ 32) + 1}'.padLeft(2, '0')}/${getDateYear(countDays)}';
  }

  // convert count days to string date;
  static String toDate(int countDays, {bool putDayName = false}) {
    final date = '${'${countDays % 32}'.padLeft(2, '0')}/${getDateMonthYear(countDays)}';
    return '$date${putDayName ? ' ${getDayName(date)}' : ''}';
  }

  // convert string date to count days;
  static int toDays(String date) {
    final normalizedDate = _normalizeDateString(date);
    final dd = normalizedDate.split('/').reversed.map((e) => int.parse(e)).toList();
    int days = 0;
    for (var i = 0; i < dd.length; i++) {
      days += _days[i] * (dd[i] - (_days[i] == 32 ? 1 : 0));
    }
    return days;
  }

  static String _normalizeDateString(String date) {
    final trimmed = date.trim();
    if (trimmed.contains('/')) {
      return trimmed.split(RegExp(r'[\s-]')).first;
    }
    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) {
      return toDateString(parsed);
    }
    throw FormatException('Invalid date format: $date');
  }

  static int toSeconds(String tm) {
    final pm = tm.endsWith('PM');
    final time = tm.substring(0, 8).split(':').map((e) => int.parse(e)).toList();
    if (time[0] == 12 && !pm) time[0] = 0;
    if (pm && time[0] != 12) time[0] += 12;
    return time.fold(0, (int pre, next) => pre * 60 + next);
  }

  static String toTime(int sec) {
    final pm = sec >= 43200;
    var currentSec = sec;
    final time = List.generate(3, (i) => (i > 0 ? currentSec = currentSec % _times[i - 1] : currentSec) ~/ _times[i]);
    if (time[0] > 12) time[0] = time[0] % 12;
    if (time[0] == 0) time[0] = 12;
    return time.map((e) => e < 10 ? '0$e' : e).join(':') + (pm ? ' PM' : ' AM');
  }
}
