import 'package:meta/meta.dart';
import 'package:omsk_events/model/event.dart';
import 'package:omsk_events/resources/repositories/abstract/event-repository.dart';
import 'package:omsk_events/resources/repositories/abstract/comment-repository.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc-base.dart';

class EventDetailsBloc extends BlocBase {
  final int _eventId;
  final EventRepository _eventRepository;
  final CommentRepository _commentRepository;

  final detailsFetcher = PublishSubject<EventFull>();

  Observable<EventFull> get event => detailsFetcher.stream;

  EventDetailsBloc(
      {@required int eventId,
      @required EventRepository eventRepository,
      @required CommentRepository commentRepository})
      : _eventId = eventId,
        _eventRepository = eventRepository,
        _commentRepository = commentRepository;

  @override
  void init() {
    loadEvent();
  }

  @override
  void dispose() {
    detailsFetcher.close();
  }

  Future<void> loadData() async {
    await loadEvent();
  }

  Future<void> loadEvent() async {
    final event = await _eventRepository.fetchEvent(_eventId);
    detailsFetcher.add(event);
  }

  Future<void> likeEvent(EventFull event) async {
    final success = await _eventRepository.likeEvent(_eventId);

    if (success.success) {
      event.liked = true;
      detailsFetcher.add(event);
    } else
      throw Exception(success.errors);
  }

  Future<void> dislikeEvent(EventFull event) async {
    final success = await _eventRepository.dislikeEvent(_eventId);

    if (success.success) {
      event.liked = false;
      detailsFetcher.add(event);
    } else
      throw Exception(success.errors);
  }

  Future<void> reportComment(int commentId) async {
    _commentRepository.reportComment(commentId);
  }
}
