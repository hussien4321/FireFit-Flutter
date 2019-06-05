import 'package:middleware/entities.dart';

class Comment {

  User commenter;
  int commentId;
  String text;
  int likesCount;
  bool isLiked;
  DateTime uploadDate;
  
  Comment({
    this.commentId,
    this.commenter,
    this.uploadDate,
    this.text,
    this.isLiked,
    this.likesCount,
  });

 
  Comment.fromMap(Map<String, dynamic> map, {bool cache = false}) :
    commentId = map['comment_id'],
    uploadDate = DateTime.parse(map['comment_created_at']),
    text = map['comment_body'],
    isLiked = map['comment_is_liked'] == 1,
    likesCount = map['comment_likes_count'] == null ? 0 : map['comment_likes_count'],
    commenter = User.fromMap(map);
    
  Map<String, dynamic> toJson() => {
    'comment_id' : commentId, 
    'commenter_user_id': commenter.userId,
    'comment_body': text,
    'comment_likes_count': likesCount,
    'comment_is_liked': isLiked ? 1 : 0,
    'comment_created_at': uploadDate?.toIso8601String(),
  };
 
}