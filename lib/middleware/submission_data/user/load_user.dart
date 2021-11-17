import '../../../middleware/middleware.dart';
class LoadUser {

  SearchModes searchMode;
  String userId;
  String username;
  String currentUserId;

  LoadUser({
    this.userId,
    this.currentUserId,
    this.username,
    this.searchMode,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'username': username,
    'current_user_id' : currentUserId,
  };
}