import 'package:omsk_events/resources/providers/shared-pref-token-provider.dart';
import 'package:omsk_events/resources/providers/token-provider.dart';
import 'package:omsk_events/resources/providers/vk-sdk-provider.dart';
import 'package:omsk_events/resources/providers/simple-vk-sdk-provider.dart';
import 'package:omsk_events/resources/repositories/abstract/album-repository.dart';
import 'package:omsk_events/resources/repositories/abstract/event-repository.dart';
import 'package:omsk_events/resources/repositories/abstract/comment-repository.dart';
import 'package:omsk_events/resources/repositories/abstract/timetable-repository.dart';
import 'package:omsk_events/resources/repositories/api-album-repository.dart';
import 'package:omsk_events/resources/repositories/api-comment-repository.dart';
import 'package:omsk_events/resources/repositories/api-cache-mediator.dart';
import 'package:omsk_events/resources/repositories/api-event-repository.dart';
import 'package:omsk_events/resources/repositories/api-timetable-repository.dart';
import 'package:omsk_events/resources/repositories/cache-repository.dart';

class DI {
  static CacheRepository _cacheRepository = CacheRepository();

  static TimetableRepository timetableRepository = ApiTimetableRepository();
  static EventRepository eventRepository =
      ApiCacheMediator(api: ApiEventRepository(), cache: _cacheRepository);
  static AlbumRepository albumRepository = ApiAlbumRepository();
  static CommentRepository commentRepository = ApiCommentRepository();

  static TokenProvider tokenProvider = SharedPreferenceTokenProvider();
  static VkSdkProvider vkSdkProvider = SimpleVkSdkProvider();
}
