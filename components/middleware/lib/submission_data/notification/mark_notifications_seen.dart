class MarkNotificationsSeen {

  String userId;
  int notificationId;

  MarkNotificationsSeen({
    this.userId,
    this.notificationId
  });

  bool get isMarkingAll => notificationId == null;

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'notification_id' : notificationId,
  };
}