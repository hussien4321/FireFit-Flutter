import 'package:middleware/entities.dart';

enum NotificationType { OUTFIT_LIKE, NEW_COMMENT, COMMENT_LIKE, NEW_FOLLOW }

class OutfitNotification {
  int notificationId;
  NotificationType type;
  DateTime createdAt;

  User referencedUser;
  Outfit referencedOutfit;
  Comment referencedComment;

  OutfitNotification({
    this.notificationId,
    this.type,
    this.createdAt,
  });
  
  static NotificationType _toNotificationType(String type) {
    switch(type.toLowerCase()){
      case 'new-comment':
        return NotificationType.NEW_COMMENT;
      case 'new-comment-like':
        return NotificationType.COMMENT_LIKE;
      case 'new-outfit-like':
        return NotificationType.OUTFIT_LIKE;
      case 'new-user-follow':
        return NotificationType.NEW_FOLLOW;
      default:
        return null;
    }
  }
  
  static String _fromNotificationType(NotificationType type) {
    switch(type){
      case NotificationType.NEW_COMMENT:
        return 'new-comment';
      case NotificationType.COMMENT_LIKE:
        return 'new-comment-like';
      case NotificationType.OUTFIT_LIKE:
        return 'new-outfit-like';
      case NotificationType.NEW_FOLLOW:
        return 'new-user-follow';
      default:
        return null;
    }
  }
  
  OutfitNotification.fromMap(Map<String, dynamic> map){
    notificationId = map['notification_id'];
    type = _toNotificationType(map['notification_type']);
    createdAt = DateTime.parse(map['notification_created_at']);
    if(map['user_id'] != null){
      referencedUser = User.fromMap(map);
    }
    if(map['outfit_id'] != null){
      referencedOutfit = Outfit.fromMap(map);
    }
    if(map['comment_id'] != null){
      referencedComment = Comment.fromMap(map);    
    }
  }   

  Map<String, dynamic> toJson() => {
    'notification_id' :  notificationId, 
    'notification_type': _fromNotificationType(type),
    'notification_created_at': createdAt.toIso8601String(),
    'notification_ref_user_id':referencedUser?.userId,
    'notification_ref_outfit_id':referencedOutfit?.outfitId,
    'notification_ref_comment_id':referencedComment?.commentId,
  };
 
 
  String get getNotificationTitle {
    switch(type){
      case NotificationType.NEW_COMMENT:
        return 'New comment';
      case NotificationType.COMMENT_LIKE:
        return 'Comment liked';
      case NotificationType.OUTFIT_LIKE:
        return 'Outfit liked';
      case NotificationType.NEW_FOLLOW:
        return 'New Follower';
      default:
        return null;
    }
  }

  String get getNotificationDescription {
    switch(type){
      case NotificationType.NEW_COMMENT:
        return 'has commented on your outfit';
      case NotificationType.COMMENT_LIKE:
        return 'has liked your comment on the outfit';
      case NotificationType.OUTFIT_LIKE:
        return 'has liked your outfit';
      case NotificationType.NEW_FOLLOW:
        return 'has started following you';
      default:
        return null;
    }
  }
}