import '../../../middleware/middleware.dart';

class CommentLike {

  String userId;
  int outfitId;
  Comment comment;

  CommentLike({
    this.userId,
    this.outfitId,
    this.comment,
  });
  
  Map<String, dynamic> toJson() => {
    'comment_is_liked': comment.isLiked ? 1 : 0,
    'comment_id': comment.commentId,
    'liker_user_id' : userId,
    'commenter_user_id' :comment.commenter.userId,
    'outfit_id' :outfitId,
  };
}