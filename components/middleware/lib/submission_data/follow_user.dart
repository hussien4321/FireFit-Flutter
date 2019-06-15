import 'package:middleware/middleware.dart';

class FollowUser {

  String followerUserId;
  User followed;

  FollowUser({
    this.followerUserId,
    this.followed,
  });

  Map<String, dynamic> toJson() => {
    'follower_user_id': followerUserId,
    'followed_user_id': followed.userId,
    'is_following' : followed.isFollowing,
  };
}