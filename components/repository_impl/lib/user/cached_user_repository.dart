import 'package:sqflite/sqflite.dart';
import 'package:middleware/middleware.dart';
import 'package:streamqflite/streamqflite.dart';
import 'package:meta/meta.dart';

class CachedUserRepository {

  StreamDatabase streamDatabase;

  CachedUserRepository({@required this.streamDatabase});

  addUser(User user, {bool isCurrentUser = false}) {
    return streamDatabase.insert(
      'user',
      user.toJson(),
      conflictAlgorithm: isCurrentUser ? ConflictAlgorithm.replace : ConflictAlgorithm.ignore,
    );
  }
  
  Stream<User> getUser(String userId){
    return streamDatabase.createQuery('user', where: "user_id = '$userId'", limit: 1).mapToOneOrDefault((data) {
      return User.fromMap(data);
    }, null).asBroadcastStream();
  }

  Stream<List<User>> getUsers(){
    return streamDatabase.createQuery('user').mapToList((data) {
      return User.fromMap(data);
    }).asBroadcastStream();
  }

  
  Future<void> deleteAll() async {
    await streamDatabase.executeAndTrigger(["user"], "DELETE FROM user");
  }

  Future<void> markNotificationsSeen(MarkNotificationsSeen markSeen) {
    streamDatabase.executeAndTrigger(['notification'], "UPDATE user SET last_seen_notification_at=?, number_of_new_notifications=0 WHERE user_id=?", [ markSeen.lastSeenNotificationAt.toIso8601String(), markSeen.userId]);
  }
  
  Future<void> followUser(FollowUser followUser){
    User user = followUser.followed;
    user.numberOfFollowers += user.isFollowing ? -1 : 1;
    user.isFollowing = !user.isFollowing;
    addUser(user, isCurrentUser: true);
    user.isFollowing = !user.isFollowing;
  }
}