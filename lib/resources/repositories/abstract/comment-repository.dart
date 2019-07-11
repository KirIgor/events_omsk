import 'package:omsk_events/model/comment.dart';

abstract class CommentRepository {
  Future<List<Comment>> fetchComments(
      {int eventId, int page = 0, int pageSize = 10});

  Future<Comment> createComment(int eventId, String text);

  Future<void> editComment(int id, String text);

  Future<void> deleteComment(int id);

  Future<void> reportComment(int commentId);
}
