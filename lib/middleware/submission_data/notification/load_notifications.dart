import '../../../middleware/entities.dart';

class LoadNotifications {

  String userId;
  bool isLive;
  DateTime lastNotificationCreatedAt;
  OutfitNotification startAfterNotification;
  
  LoadNotifications({
    this.userId,
    this.isLive,
    this.startAfterNotification,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'last_notification_created_at':lastNotificationCreatedAt?.toIso8601String(),
    'start_after_notification':startAfterNotification?.toJson(),
  };

  
  bool operator ==(o) {
    return o is LoadNotifications &&
    o.startAfterNotification != null && startAfterNotification != null &&
    o.userId == userId &&
    o.isLive == isLive &&
    o.lastNotificationCreatedAt == lastNotificationCreatedAt &&
    o.startAfterNotification?.notificationId == startAfterNotification?.notificationId;
  }
}