import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omsk_events/model/event-short.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class EventItem extends StatelessWidget {
  final EventShort _event;
  final Color _markerColor;

  static const double _HORIZONTAL_PADDING = 16.0;

  EventItem({@required EventShort event, @required Color markerColor})
      : _event = event,
        _markerColor = markerColor;

  void _onShowDetails(BuildContext context) {
    Navigator.of(context).pushNamed("/event_details", arguments: _event.id);
  }

  void _onShareClick(BuildContext context) {
    Share.plainText(
            title: _event.name,
            text: _event.mainImage ??
                "" + "\n" + _event.name + "\n" + _event.description ??
                "")
        .share();
  }

  Widget getMainPhoto() {
    if (_event.mainImage != null && _event.mainImage.isNotEmpty) {
      return FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          image: _event.mainImage,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover);
    }
    return Container();
  }

  Widget getDescription() {
    if (_event.description != null) {
      return Container(
        margin: EdgeInsets.only(
            top: 8, left: _HORIZONTAL_PADDING, right: _HORIZONTAL_PADDING),
        child: Text(_event.description,
            maxLines: 2,
            style: TextStyle(color: Colors.grey),
            overflow: TextOverflow.ellipsis),
      );
    }
    return Container();
  }

  bool isPast() {
    final currentMillis = DateTime.now().millisecondsSinceEpoch;
    return (_event.endDateTime?.millisecondsSinceEpoch ?? currentMillis) <
        currentMillis;
  }

  Widget buildTitle(){
    if (_event.isBig){
      return Text(_event.name,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87);
    }

    return Text(_event.name,
          style: TextStyle(
              fontSize: 20,
              color: Colors.black87);
  }

  Widget getBody(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(8),
      child: Card(
          elevation: 2,
          child: Material(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                  onTap: () => _onShowDetails(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      getMainPhoto(),
                      Container(
                        padding: EdgeInsets.only(
                            top: 8,
                            left: _HORIZONTAL_PADDING,
                            right: _HORIZONTAL_PADDING),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(children: <Widget>[
                              Container(
                                  margin: EdgeInsets.only(right: 8),
                                  child: CircleAvatar(
                                      backgroundColor: _markerColor,
                                      minRadius: 8,
                                      maxRadius: 8)),
                              Expanded(
                                  child: buildTitle(),
                              )
                            ]),
                            Container(
                                margin: EdgeInsets.only(top: 8),
                                child: Row(children: <Widget>[
                                  Icon(Icons.calendar_today,
                                      color: Colors.black45, size: 16.0),
                                  Container(
                                      margin: EdgeInsets.only(left: 4),
                                      child: Text(
                                          DateFormat("dd.MM.yyyy, H:mm")
                                              .format(_event.startDateTime),
                                          style:
                                              TextStyle(color: Colors.black45)))
                                ]))
                          ],
                        ),
                      ),
                      getDescription(),
                      Container(
                          margin:
                              EdgeInsets.only(top: 8, left: 12.0, right: 4.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.group, color: Colors.black54),
                                    Container(
                                        margin:
                                            EdgeInsets.only(left: 4, right: 8),
                                        child: Text(
                                            _event.likesCount.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black54))),
                                    Icon(Icons.comment, color: Colors.black54),
                                    Container(
                                        margin: EdgeInsets.only(left: 4),
                                        child: Text(
                                            _event.commentsCount.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black54)))
                                  ],
                                ),
                                IconButton(
                                    icon: Icon(Icons.share,
                                        color: Colors.black54),
                                    onPressed: () => _onShareClick(context))
                              ]))
                    ],
                  )))),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_event.isOnGoing()) {
      return Banner(
          message: "Уже идет",
          color: Colors.green,
          location: BannerLocation.topEnd,
          child: getBody(context));
    }

    return getBody(context);
  }
}
