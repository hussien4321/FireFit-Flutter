import 'package:middleware/entities.dart';

enum NotificationType { OUTFIT_LIKE, NEW_COMMENT, COMMENT_LIKE }

class OutfitNotification {
  int notificationId;
  String referenceId;
  NotificationType type;
  DateTime createdAt;

  User referencedUser;
  Outfit referencedOutfit;

  OutfitNotification({
    this.notificationId,
    this.referenceId,
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
      default:
        return null;
    }
  }
  
  OutfitNotification.fromMap(Map<String, dynamic> map) :
    notificationId = map['notification_id'],
    type = _toNotificationType(map['notification_type']),
    createdAt = DateTime.parse(map['notification_created_at']),
    referenceId = map['notification_reference_id'],
    referencedUser = User.fromMap(map),
    referencedOutfit = Outfit.fromMap(map);
    
  Map<String, dynamic> toJson() => {
    'notification_id' :  notificationId, 
    'notification_type': _fromNotificationType(type),
    'notification_created_at': createdAt.toIso8601String(),
    'notification_reference_id': referenceId,
  };
 
 
  String get getNotificationTitle {
    switch(type){
      case NotificationType.NEW_COMMENT:
        return 'New comment';
      case NotificationType.COMMENT_LIKE:
        return 'Comment liked';
      case NotificationType.OUTFIT_LIKE:
        return 'Outfit liked';
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
      default:
        return null;
    }
  }
}