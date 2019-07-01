import 'package:middleware/entities.dart';

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
    print('comparing 1 ${o is LoadNotifications}');
    print('comparing 2 ${userId} -> ${o.userId}');
    print('comparing 3 ${isLive} -> ${o.isLive}');
    print('comparing 4 ${lastNotificationCreatedAt} -> ${o.lastNotificationCreatedAt}');
    print('comparing 5 ${startAfterNotification?.notificationId} -> ${o.startAfterNotification?.notificationId}');
    return o is LoadNotifications &&
    o.userId == userId &&
    o.isLive == isLive &&
    o.lastNotificationCreatedAt == lastNotificationCreatedAt &&
    o.startAfterNotification?.notificationId == startAfterNotification?.notificationId;
  }
}