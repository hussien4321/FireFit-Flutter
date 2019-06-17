import 'package:sqflite/sqflite.dart';
import 'package:middleware/middleware.dart';
import 'package:streamqflite/streamqflite.dart';
import 'package:meta/meta.dart';
import 'dart:async';

class CachedUserRepository {

  StreamDatabase streamDatabase;

  CachedUserRepository({@required this.streamDatabase});

  Future<int> addUser(User user, SearchModes searchMode) async {
    await _addUserSearch(user.userId, searchMode);
    return _addUser(user);
  }
  Future<int> _addUser(User user) async {
    return streamDatabase.insert(
      'user',
      user.toJson(),
      conflictAlgorithm: user.hasFullData ? ConflictAlgorithm.replace : ConflictAlgorithm.ignore,
    );
  }

  Future<int> _addUserSearch(String userId, SearchModes searchMode) async {
    SearchUser searchUser = SearchUser(
      userId: userId,
      searchMode: searchModeToString(searchMode),
    );
    return streamDatabase.insert(
      'user_search',
      searchUser.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Stream<User> loadUser(SearchModes searchMode){
    String searchModeString = searchModeToString(searchMode);
    return streamDatabase.createRawQuery(['user'], 'SELECT * FROM user, user_search WHERE user_id=search_user_id AND search_user_mode=? LIMIT 1',[searchModeString]).mapToOneOrDefault((data) {
      return User.fromMap(data);
    }, null).asBroadcastStream();
  }

  Stream<List<User>> loadUsers(SearchModes searchMode) {
    String searchModeString = searchModeToString(searchMode);
    return streamDatabase.createRawQuery(['user'], 'SELECT * FROM user, user_search WHERE user_id=search_user_id AND search_user_mode=?',[searchModeString]).mapToList((data) {
      return User.fromMap(data);
    }).asBroadcastStream();
  }

  
  Future<void> clearAllUsers() async {
    await streamDatabase.executeAndTrigger(["user"], "DELETE FROM user");
  }
  
  Future<void> clearUsers(SearchModes searchMode) async {
    await _clearUserSearches(searchMode);
    await _clearUsers(searchMode);
  }
  Future<void> _clearUserSearches(SearchModes searchMode) async {
    String searchModeString = searchModeToString(searchMode);
    await streamDatabase.execute("DELETE FROM user_search WHERE search_user_mode=?", [searchModeString]);
  }
  Future<void> _clearUsers(SearchModes searchMode) async {
    String searchModeString =searchModeToString(searchMode);
    await streamDatabase.executeAndTrigger(['user'], "DELETE FROM user WHERE (SELECT COUNT(*) FROM user_search WHERE search_user_id=user_id AND search_user_mode=?)=1 AND (SELECT COUNT(*) FROM user_search WHERE search_user_id=user_id AND search_user_mode!=?)=0", [searchModeString, searchModeString]);
  }


  Future<void> markNotificationsSeen(MarkNotificationsSeen markSeen) {
    return streamDatabase.executeAndTrigger(['notification'], "UPDATE user SET last_seen_notification_at=?, number_of_new_notifications=0 WHERE user_id=?", [ markSeen.lastSeenNotificationAt.toIso8601String(), markSeen.userId]);
  }

  Future<void> followUser(FollowUser followUser) async {
    User user = followUser.followed;
    int numberOfFollowsChange = user.isFollowing ? -1 : 1;
    bool isFollowing = !user.isFollowing;
    await streamDatabase.executeAndTrigger(['user'], "UPDATE user SET is_following=?, number_of_followers=number_of_followers+? WHERE user_id=?", [isFollowing ? 1 : 0, numberOfFollowsChange, user.userId]);
    return streamDatabase.executeAndTrigger(['user'], "UPDATE user SET number_of_following=number_of_following+? WHERE user_id=?", [numberOfFollowsChange, followUser.followerUserId]);
  }

  Future<void> clearNewFeed() {
    String searchModeString =searchModeToString(SearchModes.MINE);
    return streamDatabase.executeAndTrigger(['user'], "UPDATE user SET has_new_feed_outfits=0 WHERE user_id=(SELECT search_user_id FROM user_search WHERE search_user_mode=? LIMIT 1)", [searchModeString]);
  }
}