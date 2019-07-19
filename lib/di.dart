import 'package:omsk_events/resources/providers/user-info-token-provider.dart';
import 'package:omsk_events/resources/providers/shared-pref-user-info-provider.dart';
import 'package:omsk_events/resources/providers/simple-vk-sdk-provider.dart';
import 'package:omsk_events/resources/providers/token-provider.dart';
import 'package:omsk_events/resources/providers/user-info-provider.dart';
import 'package:omsk_events/resources/providers/vk-sdk-provider.dart';
import 'package:omsk_events/resources/providers/privacy-policy-accepted-provider.dart';
import 'package:omsk_events/resources/providers/shared-pref-privacy-policy-accepted-provider.dart';
import 'package:omsk_events/resources/repositories/abstract/album-repository.dart';
import 'package:omsk_events/resources/repositories/abstract/comment-repository.dart';
import 'package:omsk_events/resources/repositories/abstract/setting-repository.dart';
import 'package:omsk_events/resources/repositories/abstract/event-repository.dart';
import 'package:omsk_events/resources/repositories/abstract/timetable-repository.dart';
import 'package:omsk_events/resources/repositories/api-album-repository.dart';
import 'package:omsk_events/resources/repositories/api-setting-repository.dart';
import 'package:omsk_events/resources/repositories/api-comment-repository.dart';
import 'package:omsk_events/resources/repositories/api-event-repository.dart';
import 'package:omsk_events/resources/repositories/api-timetable-repository.dart';
import 'package:omsk_events/utils/date-converter.dart';
import 'package:omsk_events/utils/omsk-date-converter.dart';

class DI {
  static TimetableRepository timetableRepository = ApiTimetableRepository();
  static EventRepository eventRepository = ApiEventRepository();
  static AlbumRepository albumRepository = ApiAlbumRepository();
  static CommentRepository commentRepository = ApiCommentRepository();
  static SettingRepository settingRepository = ApiSettingRepository();

  static TokenProvider tokenProvider = UserInfoTokenProvider();
  static UserInfoProvider userInfoProvider = SharedPreferenceUserInfoProvider();
  static PrivacyPolicyAcceptedProvider acceptedProvider =
      SharedPreferencePrivacyPolicyAcceptedProvider();
  static VkSdkProvider vkSdkProvider = SimpleVkSdkProvider();

  static DateConverter dateConverter = OmskDateConverter();
}
