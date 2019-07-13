import 'package:flutter/material.dart';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';

import 'package:omsk_events/bloc/bloc-widget.dart';
import 'package:omsk_events/bloc/event-details-bloc.dart';
import 'package:omsk_events/bloc/user-bloc.dart';
import 'package:omsk_events/resources/providers/token-provider.dart';
import 'package:omsk_events/resources/providers/user-info-provider.dart';
import 'package:omsk_events/di.dart';
import 'package:omsk_events/model/event.dart';
import 'package:omsk_events/model/comment.dart';

import 'dart:math';

import 'gallery-page.dart';

enum ActionsTypes { addToCalendar }

void addToCalendar(EventFull event) {
  final Event addedEvent = Event(
    title: event.name,
    description: event.description,
    location: event.address,
    startDate: event.startDateTime,
    endDate: event.endDateTime ?? event.startDateTime,
  );

  Add2Calendar.addEvent2Cal(addedEvent);
}

class EventPage extends StatefulWidget {
  final int eventId;

  EventPage({Key key, @required this.eventId}) : super(key: key);

  final double _topBarHeight = 200;

  @override
  State<StatefulWidget> createState() => _EventPageState(eventId);
}

class _EventPageState extends State<EventPage> with TickerProviderStateMixin {
  ScrollController _controller = ScrollController();
  double _offset = 0.0;

  final int eventId;
  EventDetailsBloc _eventDetailsBloc;
  UserBloc _userBloc;

  PagewiseLoadController<Comment> _pagewiseLoadController;

  AnimationController _animationController;
  Animation _commentFadeAnimation;

  _EventPageState(this.eventId);

  @override
  void initState() {
    super.initState();

    _eventDetailsBloc = BlocWidget.of(context);
    _userBloc = BlocWidget.of(context);

    _pagewiseLoadController = PagewiseLoadController(
        pageFuture: (pageIndex) {
          return DI.commentRepository
              .fetchComments(eventId: eventId, page: pageIndex);
        },
        pageSize: 10);

    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _commentFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _controller.addListener(() {
      setState(() {
        _offset = _controller.offset;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pagewiseLoadController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<Widget> _buildActions(EventFull event) {
    return [
      IconButton(
        icon: const Icon(Icons.share),
        tooltip: "Поделиться",
        onPressed: () => _share(event),
      ),
      PopupMenuButton<ActionsTypes>(
        tooltip: "Меню",
        onSelected: (ActionsTypes t) {
          if (t == ActionsTypes.addToCalendar) {
            addToCalendar(event);
          }
        },
        itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                  value: ActionsTypes.addToCalendar,
                  child: Text("Добавить в календарь"))
            ],
      )
    ];
  }

  Widget _buildFlexibleSpaceBar(EventFull event) {
    final title = event.name.length > 17
        ? '${event.name.substring(0, 17)}...'
        : event.name;

    return FlexibleSpaceBar(
        title:
            Opacity(opacity: _opacityFromOffset(_offset), child: Text(title)),
        background: Carousel(
            dotSize: 10,
            dotIncreaseSize: 1.3,
            autoplayDuration: const Duration(seconds: 5),
            boxFit: BoxFit.fitWidth,
            images:
                event.photos.map((photo) => NetworkImage(photo.src)).toList()));
  }

  Widget _buildFloatingActionButton(EventFull event) {
    return Positioned(
        top: 195.0 - _offset,
        right: 16.0,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..scale(_scaleFromOffset(_offset)),
          child: FloatingActionButton(
            onPressed: () => onLikeOrDislike(event),
            child: Icon(event.liked ? Icons.person : Icons.person_outline),
          ),
        ));
  }

  bool isOnGoing(_event) {
    final currentMillis = DateTime.now().millisecondsSinceEpoch;
    return (_event.startDateTime.millisecondsSinceEpoch <= currentMillis &&
        currentMillis <=
            (_event.endDateTime?.millisecondsSinceEpoch ?? currentMillis));
  }

  Widget getBody(EventFull event, UserInfo userInfo) {
    return Stack(
      children: <Widget>[
        CustomScrollView(
          controller: _controller,
          slivers: <Widget>[
            SliverAppBar(
                expandedHeight: widget._topBarHeight,
                pinned: true,
                floating: false,
                snap: false,
                actions: _buildActions(event),
                flexibleSpace: _buildFlexibleSpaceBar(event)),
            SliverList(
                delegate: SliverChildListDelegate(<Widget>[
              EventPageInfo(event: event),
              EventPageMap(event: event),
              EventPageContact(event: event),
              EventPageToAlbumAndVK(event: event),
              EventPageCommentForm(
                pagewiseLoadController: _pagewiseLoadController,
                commentFadeAnimationController: _animationController,
                event: event,
                userInfo: userInfo,
              )
            ])),
            EventPageComments(
                bloc: _eventDetailsBloc,
                event: event,
                userInfo: userInfo,
                pagewiseLoadController: _pagewiseLoadController,
                commentFadeAnimation: _commentFadeAnimation)
          ],
        ),
        _buildFloatingActionButton(event)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(),
      child: Scaffold(
          body: StreamBuilder(
              stream: _userBloc.userInfo,
              builder: (context, userSnapshot) {
                return StreamBuilder(
                    stream: _eventDetailsBloc.event,
                    builder: (context, eventSnapshot) {
                      if (userSnapshot.connectionState ==
                              ConnectionState.active &&
                          eventSnapshot.connectionState ==
                              ConnectionState.active) {
                        UserInfo userInfo = userSnapshot.data;
                        EventFull event = eventSnapshot.data;
                        return getBody(event, userInfo);
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    });
              })),
    );
  }

  double _normalizeFromTo(double from, double to, double value) {
    return min(max(0, value - from), to - from) / (to - from);
  }

  double _opacityFromOffset(double offset) {
    return Curves.easeIn.transform(_normalizeFromTo(
        widget._topBarHeight / 2 - 10, widget._topBarHeight / 2 + 30, offset));
  }

  double _scaleFromOffset(double offset) {
    return 1 -
        Curves.easeOut.transform(_normalizeFromTo(
            widget._topBarHeight / 2 - 10, widget._topBarHeight / 2, offset));
  }

  void _share(EventFull event) {
    final firstImage = event.mainPhoto;

    Share.plainText(
            text: "${firstImage ?? ""}\n"
                "${event.name}\n"
                "${event.description ?? ""}")
        .share();
  }

  void onLikeOrDislike(EventFull event) async {
    try {
      if (event.liked)
        await _eventDetailsBloc.dislikeEvent(event);
      else
        await _eventDetailsBloc.likeEvent(event);
    } on NotAuthorizedException {
      Navigator.pushNamed(context, "/auth");
    }
  }
}

class EventPageInfo extends StatelessWidget {
  final EventFull event;

  const EventPageInfo({Key key, this.event}) : super(key: key);

  Widget _buildDescription(EventFull event) {
    if (event.description != null) {
      return ListTile(title: Text(event.description ?? ""));
    } else {
      return Container();
    }
  }

  Widget buildTitle() {
    if (event.isBig)
      return ListTile(
        leading: Icon(Icons.stars, size: 30),
        title: Text(event.name,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
      );

    return ListTile(
      title: Text(event.name,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
      child: Column(
        children: <Widget>[
          Container(
              margin: const EdgeInsets.only(top: 25), child: buildTitle()),
          ListTile(
              title: Text(event.eventTimeBounds(),
                  style: const TextStyle(fontStyle: FontStyle.italic)),
              trailing: const Icon(
                Icons.event_note,
                size: 30,
              ),
              onTap: () => addToCalendar(event)),
          _buildDescription(event),
        ],
      ),
      padding: const EdgeInsets.only(bottom: 20),
    ));
  }
}

class EventPageMap extends StatelessWidget {
  final EventFull event;

  const EventPageMap({Key key, this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: GoogleMap(
        markers: Set<Marker>()
          ..add(Marker(
              markerId: MarkerId("first"),
              position: LatLng(event.latitude, event.longitude))),
        initialCameraPosition: CameraPosition(
            target: LatLng(event.latitude, event.longitude), zoom: 15),
        scrollGesturesEnabled: false,
        tiltGesturesEnabled: false,
        rotateGesturesEnabled: false,
        zoomGesturesEnabled: false,
      ),
    );
  }
}

class EventPageContact extends StatelessWidget {
  final EventFull event;

  const EventPageContact({Key key, this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (event.phone != null) {
      return Card(
        child: ListTile(
          leading: Icon(Icons.phone,
              color: Theme.of(context).primaryColor, size: 30),
          title: Text(event.address ?? ""),
          subtitle: Text(event.phone),
          onTap: () => _openPhone(event),
        ),
      );
    } else {
      return Container();
    }
  }

  void _openPhone(EventFull event) {
    launch("tel:${event.phone}");
  }
}

class EventPageToAlbumAndVK extends StatelessWidget {
  final EventFull event;

  const EventPageToAlbumAndVK({Key key, this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;

    return Card(
        child: Column(
      children: <Widget>[
        event.hasAlbums
            ? ListTile(
                leading: Icon(Icons.photo_album, color: color, size: 30),
                title: const Text("Все фотографии"),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return GalleryPage(eventId: event.id);
                  }));
                },
              )
            : Container(),
        event.externalRef != null
            ? ListTile(
                leading: Icon(Icons.language, color: color, size: 30),
                title: const Text("Подробнее о событии"),
                onTap: () {
                  launch(event.externalRef);
                },
              )
            : Container(),
      ],
    ));
  }
}

class EventPageCommentForm extends StatefulWidget {
  final EventFull event;
  final UserInfo userInfo;
  final PagewiseLoadController pagewiseLoadController;
  final AnimationController commentFadeAnimationController;

  const EventPageCommentForm(
      {Key key,
      this.pagewiseLoadController,
      this.commentFadeAnimationController,
      this.event,
      this.userInfo})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => EventPageCommentFormState();
}

class EventPageCommentFormState extends State<EventPageCommentForm> {
  FocusNode _focusNode = FocusNode();
  TextEditingController _textEditingController = TextEditingController();
  GlobalKey<FormState> _formState = GlobalKey();

  UserBloc _userBloc;

  @override
  void initState() {
    super.initState();

    _userBloc = BlocWidget.of<UserBloc>(context);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && widget.userInfo == null) {
        _focusNode.unfocus();
        Navigator.pushNamed(context, "/auth");
      }
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 30),
        child: Column(children: <Widget>[
          ListTile(
            title: Form(
                key: _formState,
                child: TextFormField(
                  focusNode: _focusNode,
                  controller: _textEditingController,
                  validator: (text) {
                    if (text.length > 255)
                      return "Максимальная длина = 255 символов";
                    else
                      return null;
                  },
                  decoration: InputDecoration(
                      labelText: "Комментарий",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _onCommentSent,
                      )),
                  minLines: 1,
                  maxLines: 3,
                )),
          )
        ]));
  }

  void _onCommentSent() {
    if (!_formState.currentState.validate()) return null;

    final text = _textEditingController.text;
    _formState.currentState.save();
    _textEditingController.text = "";

    // dismiss keyboard
    FocusScope.of(context).requestFocus(new FocusNode());

    DI.commentRepository.createComment(widget.event.id, text).then((comment) {
      comment.justCreated = true;

      widget.commentFadeAnimationController.reset();
      widget.commentFadeAnimationController.forward();

      widget.pagewiseLoadController.loadedItems.insert(0, comment);
      widget.pagewiseLoadController.notifyListeners();
    });
  }
}

class EventPageComments extends StatelessWidget {
  final EventFull event;
  final UserInfo userInfo;
  final PagewiseLoadController<Comment> pagewiseLoadController;
  final Animation<double> commentFadeAnimation;
  final EventDetailsBloc bloc;

  const EventPageComments(
      {Key key,
      this.event,
      this.pagewiseLoadController,
      this.commentFadeAnimation,
      this.userInfo,
      this.bloc})
      : super(key: key);

  void onReportComment(BuildContext context, Comment c) async {
    await bloc.reportComment(c.id);
    pagewiseLoadController.reset();
  }

  Widget _buildComment(BuildContext context, Comment c) {
    return PopupMenuButton<String>(
        itemBuilder: (context) => userInfo.vkId != null
            ? <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  child: Text("Пожаловаться"),
                  value: "report",
                )
              ]
            : [],
        onSelected: (value) {
          if (value == "report") {
            onReportComment(context, c);
          }
        },
        child: Container(
            key: Key(c.id.toString()),
            margin: const EdgeInsets.only(top: 10),
            child: ListTile(
              leading: GestureDetector(
                  onTap: () {
                    if (c.vkId != null) launch("https://vk.com/id${c.vkId}");
                  },
                  child: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(c.userAvatar),
                  )),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    c.userName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: Text(
                        c.text,
                        style: const TextStyle(fontSize: 14),
                      )),
                  Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: Text(
                        DateFormat("d MMMM y H:mm", "ru_RU")
                            .format(c.modifiedAt),
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                      ))
                ],
              ),
            )));
  }

  Widget _buildDismissible(BuildContext context, int index, Comment c) {
    final dismissBackground = Container(
      color: Colors.red,
      child: ListTile(
        leading: Icon(Icons.delete, color: Colors.white, size: 36.0),
      ),
    );

    if (userInfo != null && userInfo.vkId == c.vkId) {
      return Dismissible(
          key: Key(c.id.toString()),
          direction: DismissDirection.horizontal,
          background: dismissBackground,
          secondaryBackground: dismissBackground,
          onDismissed: (direction) {
            pagewiseLoadController.loadedItems.removeAt(index);
            DI.commentRepository.deleteComment(c.id);
          },
          child: _buildComment(context, c));
    } else
      return _buildComment(context, c);
  }

  @override
  Widget build(BuildContext context) {
    return PagewiseSliverList<Comment>(
      pageLoadController: pagewiseLoadController,
      itemBuilder: (context, c, index) {
        if (index == 0 && c.justCreated) {
          return FadeTransition(
              opacity: commentFadeAnimation,
              child: _buildDismissible(context, index, c));
        } else
          return _buildDismissible(context, index, c);
      },
    );
  }
}
