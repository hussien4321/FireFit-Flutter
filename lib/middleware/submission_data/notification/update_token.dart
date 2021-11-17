class UpdateToken {
  String userId, token;

  UpdateToken({
    this.userId,
    this.token,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'notification_token':token,
  };

}