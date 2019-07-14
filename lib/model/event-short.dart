import 'package:intl/intl.dart';

import 'setting.dart';
import 'event.dart';

class EventShort {
  int _id;
  String _name;
  String _description;
  DateTime _startDateTime;
  DateTime _endDateTime;
  double _latitude;
  double _longitude;
  int _likesCount;
  String _mainImage;
  bool _isBig;
  int _commentsCount;

  EventShort({int id, DateTime startDateTime})
      : _id = id,
        _startDateTime = startDateTime;

  EventShort.fromJson(Map<String, dynamic> parsedJson) {
    _id = parsedJson["id"];
    _name = parsedJson["name"];
    _description = parsedJson["description"];
    _startDateTime = DateTime.parse(parsedJson["startDateTime"]).toLocal();
    _endDateTime = parsedJson["endDateTime"] != null
        ? DateTime.parse(parsedJson["endDateTime"]).toLocal()
        : null;
    _latitude = parsedJson["latitude"];
    _longitude = parsedJson["longitude"];
    _likesCount = parsedJson["likesCount"];
    _mainImage = parsedJson["mainImage"];
    _isBig = parsedJson["big"];
    _commentsCount = parsedJson["commentsCount"];
  }

  EventShort.fromEventFull(EventFull e) {
    _id = e.id;
    _name = e.name;
    _description = e.description;
    _startDateTime = e.startDateTime;
    _endDateTime = e.endDateTime;
    _latitude = e.latitude;
    _longitude = e.longitude;
    _likesCount = e.likesCount;
    _mainImage = e.mainPhoto;
    _isBig = e.isBig;
    _commentsCount = 0;
  }

  String eventTimeBounds() {
    if (endDateTime == null)
      return "${DateFormat("d MMMM, H:mm", "ru_RU").format(startDateTime)}";

    if (startDateTime.year == endDateTime.year &&
        startDateTime.month == endDateTime.month &&
        startDateTime.day == endDateTime.day) {
      return "${DateFormat("d MMMM, H:mm", "ru_RU").format(startDateTime)}–${DateFormat("Hm", "ru_RU").format(endDateTime)}";
    } else {
      return "${DateFormat("d MMMM, H:mm", "ru_RU").format(startDateTime)} — ${DateFormat("d MMMM, H:mm", "ru_RU").format(endDateTime)}";
    }
  }

  DateTime _dateWithoutTime(DateTime dateTime) => dateTime == null
      ? null
      : DateTime(dateTime.year, dateTime.month, dateTime.day);

  bool isMultidayAndWithinSpecialDates(List<Setting> settings) {
    if (endDateTime == null) return false;

    final startDate = _dateWithoutTime(startDateTime);
    final endDate = _dateWithoutTime(endDateTime);

    if (startDate == endDate) return false;

    final specialDates = settings
        .where((setting) => setting.key.startsWith("SPECIAL_DATE"))
        .toList();

    return specialDates.any((setting) {
      final specialDate = _dateWithoutTime(DateTime.parse(setting.value));
      return (startDate.millisecondsSinceEpoch <=
              specialDate.millisecondsSinceEpoch &&
          endDate.millisecondsSinceEpoch >= specialDate.millisecondsSinceEpoch);
    });
  }

  EventType getEventType(List<Setting> settings) {
    final now = DateTime.now();

    final startDate = _dateWithoutTime(startDateTime);
    final endDate = _dateWithoutTime(endDateTime);

    final specialDate1 = _dateWithoutTime(DateTime.parse(settings
        .firstWhere((setting) => setting.key == "SPECIAL_DATE_1")
        .value));
    final specialDate2 = _dateWithoutTime(DateTime.parse(settings
        .firstWhere((setting) => setting.key == "SPECIAL_DATE_2")
        .value));
    final specialDate3 = _dateWithoutTime(DateTime.parse(settings
        .firstWhere((setting) => setting.key == "SPECIAL_DATE_3")
        .value));

    if (endDateTime != null) {
      if (endDateTime.isBefore(now)) return EventType.PAST;
      if (isToday()) return EventType.CURRENT;
      if (isMultidayAndWithinSpecialDates(settings))
        return EventType.MULTIDAY_WITHIN_SPECIAL_DATES;
      if (startDate == endDate) {
        if (startDate == specialDate1)
          return EventType.SPECIAL_DATE_1;
        else if (startDate == specialDate2)
          return EventType.SPECIAL_DATE_2;
        else if (startDate == specialDate3) return EventType.SPECIAL_DATE_3;
      }
    } else {
      if (startDateTime.isBefore(now)) return EventType.PAST;
      if (isToday()) return EventType.CURRENT;

      if (startDate == specialDate1)
        return EventType.SPECIAL_DATE_1;
      else if (startDate == specialDate2)
        return EventType.SPECIAL_DATE_2;
      else if (startDate == specialDate3) return EventType.SPECIAL_DATE_3;
    }
    return EventType.FUTURE;
  }

  bool isToday() {
    final now = DateTime.now();
    final nowDate = _dateWithoutTime(now);

    final startDate = _dateWithoutTime(startDateTime);

    if (endDateTime != null) {
      return startDate.millisecondsSinceEpoch <=
              nowDate.millisecondsSinceEpoch &&
          endDateTime.millisecondsSinceEpoch >= now.millisecondsSinceEpoch;
    } else {
      return startDate == nowDate &&
          startDateTime.millisecondsSinceEpoch >= now.millisecondsSinceEpoch;
    }
  }

  bool isOnGoing() {
    if (endDateTime == null) return false;

    final now = DateTime.now();
    return startDateTime.isBefore(now) && endDateTime.isAfter(now);
  }

  int get id => _id;
  String get name => _name;
  String get description => _description;
  DateTime get startDateTime => _startDateTime;
  DateTime get endDateTime => _endDateTime;
  double get latitude => _latitude;
  double get longitude => _longitude;
  int get likesCount => _likesCount;
  String get mainImage => _mainImage;
  bool get isBig => _isBig;
  int get commentsCount => _commentsCount;
}

enum EventType {
  CURRENT,
  MULTIDAY_WITHIN_SPECIAL_DATES,
  SPECIAL_DATE_1,
  SPECIAL_DATE_2,
  SPECIAL_DATE_3,
  FUTURE,
  PAST
}
