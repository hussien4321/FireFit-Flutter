class LoadNotifications {

  String userId;
  bool isLive;
  
  LoadNotifications({
    this.userId,
    this.isLive,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
  };
}