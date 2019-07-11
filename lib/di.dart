import 'package:omsk_events/resources/providers/shared-pref-token-provider.dart';
import 'package:omsk_events/resources/providers/simple-vk-sdk-provider.dart';
import 'package:omsk_events/resources/providers/token-provider.dart';
import 'package:omsk_events/resources/providers/vk-sdk-provider.dart';
import 'package:omsk_events/resources/repositories/abstract/album-repository.dart';
import 'package:omsk_events/resources/repositories/abstract/comment-repository.dart';
import 'package:omsk_events/resources/repositories/abstract/event-repository.dart';
import 'package:omsk_events/resources/repositories/abstract/timetable-repository.dart';
import 'package:omsk_events/resources/repositories/api-album-repository.dart';
import 'package:omsk_events/resources/repositories/api-comment-repository.dart';
import 'package:omsk_events/resources/repositories/api-event-repository.dart';
import 'package:omsk_events/resources/repositories/api-timetable-repository.dart';

class DI {
  static TimetableRepository timetableRepository = ApiTimetableRepository();
  static EventRepository eventRepository = ApiEventRepository();
  static AlbumRepository albumRepository = ApiAlbumRepository();
  static CommentRepository commentRepository = ApiCommentRepository();

  static TokenProvider tokenProvider = SharedPreferenceTokenProvider();
  static VkSdkProvider vkSdkProvider = SimpleVkSdkProvider();
}
