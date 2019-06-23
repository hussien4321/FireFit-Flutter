import 'package:middleware/middleware.dart';

class AddComment {

  String userId;
  Outfit outfit;
  String commentText;

  AddComment({
    this.userId,
    this.outfit,
    this.commentText,
  });

  Map<String, dynamic> toJson() => {
    'commenter_user_id': userId,
    'poster_user_id': outfit.poster.userId,
    'comment_outfit_id' : outfit.outfitId,
    'comment_body' :commentText,
  };
}