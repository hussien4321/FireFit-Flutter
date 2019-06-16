import 'package:middleware/middleware.dart';
class LoadUser {

  SearchModes searchMode;
  String userId;
  String currentUserId;

  LoadUser({
    this.userId,
    this.currentUserId,
    this.searchMode,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'current_user_id' : currentUserId,
  };
}