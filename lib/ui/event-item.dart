import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omsk_events/bloc/bloc-widget.dart';
import 'package:omsk_events/bloc/event-list-bloc.dart';
import 'package:omsk_events/model/event-short.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class EventItem extends StatelessWidget {
  final EventShort _event;

  static const double _HORIZONTAL_PADDING = 16.0;

  EventItem({@required EventShort event}) : _event = event;

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
    if (_event.mainImage != null) {
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

  @override
  Widget build(BuildContext context) {
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
                            Text(_event.name,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
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
                                    Icon(Icons.favorite, color: Colors.black54),
                                    Container(
                                        margin: EdgeInsets.only(left: 4),
                                        child: Text(
                                            _event.likesCount.toString(),
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
}
