class GetUser {

  String userId;
  String currentUserId;

  GetUser({
    this.userId,
    this.currentUserId,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'current_user_id' : currentUserId,
  };
}