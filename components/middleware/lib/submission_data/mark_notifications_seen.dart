import 'package:middleware/middleware.dart';

class MarkNotificationsSeen {

  String userId;
  DateTime lastSeenNotificationAt;

  MarkNotificationsSeen({
    this.userId,
    this.lastSeenNotificationAt,
  }){
    if(lastSeenNotificationAt == null){
      lastSeenNotificationAt = new DateTime.now();
    }
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'last_seen_notification_at' : lastSeenNotificationAt.toIso8601String(),
  };
}