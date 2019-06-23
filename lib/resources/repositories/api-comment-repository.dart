import 'package:omsk_events/model/comment.dart';
import 'package:omsk_events/resources/repositories/abstract/comment-repository.dart';
import 'package:omsk_events/resources/providers/comment-api-provider.dart';

import '../../di.dart';

class ApiCommentRepository implements CommentRepository {
  final commentsProvider = CommentAPIProvider(tokenProvider: DI.tokenProvider);

  @override
  Future<Comment> createComment(int eventId, String text) =>
      commentsProvider.createComment(eventId: eventId, text: text);

  @override
  Future<void> deleteComment(int id) =>
      commentsProvider.deleteComment(commentId: id);

  @override
  Future<void> editComment(int id, String text) =>
      commentsProvider.editComment(commentId: id, text: text);

  @override
  Future<List<Comment>> fetchComments(
          {int eventId, int page = 0, int pageSize = 10}) =>
      commentsProvider.fetchComments(
          eventId: eventId, page: page, pageSize: pageSize);
}
