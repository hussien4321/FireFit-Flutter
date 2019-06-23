class LoadNotifications {

  String userId;
  bool isLive;
  DateTime lastNotificationCreatedAt;
  
  LoadNotifications({
    this.userId,
    this.isLive,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'last_notification_created_at':lastNotificationCreatedAt?.toIso8601String()
  };
}