import 'package:flutter/material.dart';
import 'package:omsk_events/model/event-short.dart';
import 'package:omsk_events/model/setting.dart';

class TransparentRoute extends PageRoute<void> {
  TransparentRoute({
    @required this.builder,
    RouteSettings settings,
  })  : assert(builder != null),
        super(settings: settings, fullscreenDialog: false);

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 350);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final result = builder(context);
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(animation),
      child: Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: result,
      ),
    );
  }
}

DateTime dateWithoutTime(DateTime dateTime) =>
    dateTime == null ? null : DateTime(dateTime.year, dateTime.month, dateTime.day);

bool isMultidayAndWithinSpecialDates(EventShort e, List<Setting> settings) {
  if (e.endDateTime == null) return false;

  final startDate = dateWithoutTime(e.startDateTime);
  final endDate = dateWithoutTime(e.endDateTime);

  if (startDate == endDate)
    return false;

  final specialDates = settings
      .where((setting) => setting.key.startsWith("SPECIAL_DATE"))
      .toList();

  return specialDates.any((setting) {
    final specialDate = dateWithoutTime(DateTime.parse(setting.value));
    return (startDate.millisecondsSinceEpoch <=
        specialDate.millisecondsSinceEpoch &&
        endDate.millisecondsSinceEpoch >= specialDate.millisecondsSinceEpoch);
  });
}

Color getEventMarkerColor(List<Setting> settings, EventShort event) {
  final withinSpecialDatesColor = Colors.purple;
  final futureColor = Colors.yellow;
  final currentColor = Colors.green;
  final pastColor = Colors.blue;
  final specialDate1Color = Colors.orange;
  final specialDate2Color = Colors.deepOrangeAccent; //dark orange
  final specialDate3Color = Colors.red;

  final now = DateTime.now();

  final startDate = dateWithoutTime(event.startDateTime);
  final endDate = dateWithoutTime(event.endDateTime);

  final specialDate1 = dateWithoutTime(DateTime.parse(settings
      .firstWhere((setting) => setting.key == "SPECIAL_DATE_1")
      .value));
  final specialDate2 = dateWithoutTime(DateTime.parse(settings
      .firstWhere((setting) => setting.key == "SPECIAL_DATE_2")
      .value));
  final specialDate3 = dateWithoutTime(DateTime.parse(settings
      .firstWhere((setting) => setting.key == "SPECIAL_DATE_3")
      .value));

  if (event.endDateTime != null) {
    if (event.endDateTime.isBefore(now)) return pastColor;
    if (isMultidayAndWithinSpecialDates(event, settings))
      return withinSpecialDatesColor;
    if (startDate == endDate) {
      if (startDate == specialDate1)
        return specialDate1Color;
      else if (startDate == specialDate2)
        return specialDate2Color;
      else if (startDate == specialDate3) return specialDate3Color;
    }
    if (event.startDateTime.isBefore(now) && event.endDateTime.isAfter(now)) {
      return currentColor;
    }
  } else {
    if (event.startDateTime.isBefore(now)) return pastColor;

    if (startDate == specialDate1)
      return specialDate1Color;
    else if (startDate == specialDate2)
      return specialDate2Color;
    else if (startDate == specialDate3) return specialDate3Color;
    if (startDate == dateWithoutTime(now)) return currentColor;
  }
  return futureColor;
}
