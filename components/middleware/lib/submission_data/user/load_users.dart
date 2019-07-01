import 'package:middleware/middleware.dart';
class LoadUsers {

  SearchModes searchMode;
  String userId;
  String currentUserId;
  User startAfterUser;

  LoadUsers({
    this.userId,
    this.currentUserId,
    this.searchMode,
    this.startAfterUser,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'current_user_id' : currentUserId,
    'start_after_user': startAfterUser?.toJson(),
  };
}