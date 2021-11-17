class UserBlock {

  String blockingUserId;
  String blockedUserId;

  UserBlock({
    this.blockedUserId,
    this.blockingUserId,
  });

  Map<String, dynamic> toJson() => {
    'blocking_user_id' : blockingUserId,
    'blocked_user_id': blockedUserId,
  };
}