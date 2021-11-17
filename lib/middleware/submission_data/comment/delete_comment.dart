import '../../../middleware/middleware.dart';

class DeleteComment {

  int outfitId;
  Comment comment;

  DeleteComment({
    this.outfitId,
    this.comment,
  });
  
  Map<String, dynamic> toJson() => {
    'comment_id': comment.commentId,
    'commenter_user_id' :comment.commenter.userId,
  };
}