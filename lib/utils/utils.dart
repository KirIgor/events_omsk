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

Color getEventMarkerColor(List<Setting> settings, EventShort event) {
  final type = event.getEventType(settings);
  final withinSpecialDatesColor = Colors.purple;
  final futureColor = Colors.yellow;
  final currentColor = Colors.green;
  final pastColor = Colors.blue;
  final specialDate1Color = Colors.orange;
  final specialDate2Color = Colors.deepOrangeAccent; //dark orange
  final specialDate3Color = Colors.red;

  switch(type){
    case EventType.CURRENT: return currentColor;
    case EventType.FUTURE: return futureColor;
    case EventType.MULTIDAY_WITHIN_SPECIAL_DATES: return withinSpecialDatesColor;
    case EventType.PAST: return pastColor;
    case EventType.SPECIAL_DATE_1: return specialDate1Color;
    case EventType.SPECIAL_DATE_2: return specialDate2Color;
    case EventType.SPECIAL_DATE_3: return specialDate3Color;
    default: throw Exception("Invalid event type");
  }
}
