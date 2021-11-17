import '../../../middleware/entities.dart';

class Comment {

  User commenter;
  int refOutfitId;
  int commentId;
  String text;
  int likesCount;
  bool isLiked;
  int replyTo;
  int repliesCount;
  DateTime uploadDate;
  
  Comment({
    this.commentId,
    this.commenter,
    this.uploadDate,
    this.text,
    this.replyTo,
    this.isLiked,
    this.repliesCount,
    this.likesCount,
  });

 
  Comment.fromMap(Map<String, dynamic> map) :
    commentId = map['comment_id'],
    uploadDate = DateTime.parse(map['comment_created_at']),
    text = map['comment_body'],
    replyTo = map['comment_reply_to'],
    isLiked = map['comment_is_liked'] == 1,
    likesCount = map['comment_likes_count'] == null ? 0 : map['comment_likes_count'],
    repliesCount = map['comment_replies_count'] == null ? 0 : map['comment_replies_count'],
    refOutfitId = map['comment_outfit_id'],
    commenter = User.fromMap(map);
    
  Map<String, dynamic> toJson() => {
    'comment_id' : commentId, 
    'comment_outfit_id' : refOutfitId, 
    'commenter_user_id': commenter.userId,
    'comment_body': text,
    'comment_reply_to': replyTo,
    'comment_likes_count': likesCount,
    'comment_replies_count': repliesCount,
    'comment_is_liked': isLiked ? 1 : 0,
    'comment_created_at': uploadDate?.toIso8601String(),
  };
 
}