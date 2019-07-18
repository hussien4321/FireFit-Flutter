import 'package:middleware/middleware.dart';

class AddComment {

  String userId;
  Outfit outfit;
  String commentText;
  Comment replyingToComment;

  AddComment({
    this.userId,
    this.outfit,
    this.commentText,
    this.replyingToComment,
  });

  Map<String, dynamic> toJson() => {
    'commenter_user_id': userId,
    'poster_user_id': outfit.poster.userId,
    'comment_outfit_id' : outfit.outfitId,
    'comment_reply_to' :replyingToComment?.commentId,
    'comment_reply_to_user_id' :replyingToComment?.commenter?.userId,
    'comment_body' :commentText,
  };
}