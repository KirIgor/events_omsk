import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omsk_events/model/event-short.dart';

class TimetableItem extends StatelessWidget {
  final EventShort _event;

  const TimetableItem({Key key, @required EventShort event})
      : _event = event,
        super(key: key);

  void _onShowDetails(BuildContext context, int eventId) {
    Navigator.of(context).pushNamed("/event_details", arguments: eventId);
  }

  bool isFinished() {
    if (_event.endDateTime != null) {
      return _event.endDateTime.millisecondsSinceEpoch <
          DateTime.now().millisecondsSinceEpoch;
    }
    return _event.startDateTime.millisecondsSinceEpoch <
        DateTime.now().millisecondsSinceEpoch;
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: isFinished() ? 0.4 : 1,
        child: Container(
          height: 80,
          alignment: Alignment.center,
          child: ListTile(
            onTap: () => _onShowDetails(context, _event.id),
            leading: CircleAvatar(
                backgroundImage: _event.mainImage == null
                    ? AssetImage("assets/grey_box.jpg")
                    : NetworkImage(_event.mainImage)),
            title: Text(_event.name),
            subtitle: Container(
              child: Row(children: <Widget>[
                Icon(Icons.date_range, color: Colors.black45, size: 16.0),
                Container(
                    margin: EdgeInsets.only(left: 4),
                    child: Text(
                      _event.eventTimeBounds(),
                      style: TextStyle(color: Colors.black45),
                    )),
              ]),
              margin: EdgeInsets.only(top: 4),
            ),
            trailing: Icon(Icons.navigate_next),
          ),
        ));
  }
}
