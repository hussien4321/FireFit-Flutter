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

  Stream<User> getUser(SearchModes searchMode){
    String searchModeString = searchModeToString(searchMode);
    return streamDatabase.createRawQuery(['user'], 'SELECT * FROM user, user_search WHERE user_id=search_user_id AND search_user_mode=? LIMIT 1',[searchModeString]).mapToOneOrDefault((data) {
      // print('userId:${data['user_id']} number_of_lookbooks:${data['number_of_lookbooks']} number_of_lookbook_outfits:${data['number_of_lookbook_outfits']}');
      return User.fromMap(data);
    }, null).asBroadcastStream();
  }

  Stream<List<User>> getUsers(SearchModes searchMode) {
    String searchModeString = searchModeToString(searchMode);
    return streamDatabase.createRawQuery(['user'], 'SELECT * FROM user, user_search WHERE user_id=search_user_id AND search_user_mode=?',[searchModeString]).mapToList((data) {
      return User.fromMap(data);
    }).asBroadcastStream();
  }

  
  Future<void> clearEverything() async {
    await streamDatabase.executeAndTrigger(["save"], "DELETE FROM save");
    await streamDatabase.executeAndTrigger(["comment"], "DELETE FROM comment");
    await streamDatabase.executeAndTrigger(["lookbook"], "DELETE FROM lookbook");
    await streamDatabase.executeAndTrigger(["user_search"], "DELETE FROM user_search");
    await streamDatabase.executeAndTrigger(["outfit_search"], "DELETE FROM outfit_search");
    await streamDatabase.executeAndTrigger(["notification"], "DELETE FROM notification");
    await streamDatabase.executeAndTrigger(["outfit"], "DELETE FROM outfit");
    return streamDatabase.executeAndTrigger(["user"], "DELETE FROM user");
  }
  
  Future<void> clearUsers(SearchModes searchMode) async {
    if(searchModesToNOTClearEachTime.every((sm) => sm!=searchMode)){
      await _clearUserSearches(searchMode);
      await _clearUsers(searchMode);
    }
  }
  Future<void> _clearUserSearches(SearchModes searchMode) async {
    String searchModeString = searchModeToString(searchMode);
    await streamDatabase.execute("DELETE FROM user_search WHERE search_user_mode=?", [searchModeString]);
  }
  Future<void> _clearUsers(SearchModes searchMode) async {
    String searchModeString =searchModeToString(searchMode);
    await streamDatabase.executeAndTrigger(['user'], "DELETE FROM user WHERE (SELECT COUNT(*) FROM user_search WHERE search_user_id=user_id AND search_user_mode=?)=1 AND (SELECT COUNT(*) FROM user_search WHERE search_user_id=user_id AND search_user_mode!=?)=0", [searchModeString, searchModeString]);
  }


  Future<void> markNotificationsSeen(MarkNotificationsSeen markSeen) async {
    if(markSeen.isMarkingAll){
      await streamDatabase.executeAndTrigger(['user'],"UPDATE user SET number_of_new_notifications=0, has_new_feed_outfits=0 WHERE user_id=?", [ markSeen.userId]);
      return streamDatabase.executeAndTrigger(['notification'], "UPDATE notification SET notification_is_seen=1 WHERE notification_id>0");
    }else{
      await streamDatabase.executeAndTrigger(['user'],"UPDATE user SET number_of_new_notifications=number_of_new_notifications-1 WHERE user_id=?", [ markSeen.userId]);
      return streamDatabase.executeAndTrigger(['notification'], "UPDATE notification SET notification_is_seen=1 WHERE notification_id=?", [ markSeen.notificationId]);
    }
  }

  incrementFlamesCount(String userId, int userRating, {bool decrement = false}) => streamDatabase.executeAndTrigger(['user'],"UPDATE user SET number_of_flames=number_of_flames${decrement?'-':'+'}? WHERE user_id=?", [ userRating, userId]);


  Future<void> incrementUserNewNotifications(List<OutfitNotification> newNotifications) async {
    //special string is needed to parse the IN query correctly
    String notificationIdsParseString = "";
    for(int i = 0; i < newNotifications.length;i++){
      notificationIdsParseString += newNotifications[i].notificationId.toString();
      if(i!=newNotifications.length-1){
        notificationIdsParseString+=", ";
      }
    }
    return streamDatabase.query(
      'notification', 
      columns: ["COUNT(*) AS 'existing_notifications'"], 
      where: 'notification_is_seen=0 AND notification_id IN ($notificationIdsParseString)', 
    ).then((res) {
      int existingNewNotifications = res[0]['existing_notifications'];
      int newNotificationsCount = newNotifications.length - existingNewNotifications;
      if(newNotificationsCount>0){
        return incrementUserNewNotificationsCount(newNotificationsCount);
      }
      return null;
    });
  }

  Future<void> incrementUserNewNotificationsCount(int newNotificationsCount) {
    String searchModeString = searchModeToString(SearchModes.MINE);
    return streamDatabase.executeAndTrigger(['user'], "UPDATE user SET number_of_new_notifications=number_of_new_notifications+? WHERE user_id=(SELECT search_user_id FROM user_search WHERE search_user_mode=? LIMIT 1)", [newNotificationsCount, searchModeString]);
  }

  Future<void> updateUserHasNewFeed() async {
    String searchModeString = searchModeToString(SearchModes.MINE);
    return streamDatabase.executeAndTrigger(['user'], "UPDATE user SET has_new_feed_outfits=1 WHERE user_id=(SELECT search_user_id FROM user_search WHERE search_user_mode=? LIMIT 1)", [searchModeString]);
  }

  Future<void> updateUserBiometrics(EditUser editUser) {
    String searchModeString = searchModeToString(SearchModes.MINE);
    return streamDatabase.executeAndTrigger(['user'], "UPDATE user SET name=?, bio=? WHERE user_id=(SELECT search_user_id FROM user_search WHERE search_user_mode=? LIMIT 1)", [editUser.name, editUser.bio, searchModeString]);
  }
  

  Future<void> followUser(FollowUser followUser) async {
    User user = followUser.followed;
    int numberOfFollowsChange = user.isFollowing ? -1 : 1;
    bool isFollowing = !user.isFollowing;
    await streamDatabase.executeAndTrigger(['user'], "UPDATE user SET is_following=?, number_of_followers=number_of_followers+? WHERE user_id=?", [isFollowing ? 1 : 0, numberOfFollowsChange, user.userId]);
    return streamDatabase.executeAndTrigger(['user'], "UPDATE user SET number_of_following=number_of_following+? WHERE user_id=?", [numberOfFollowsChange, followUser.followerUserId]);
  }

  Future<void> addBlock(Block block) async {
    return streamDatabase.insert(
      'block',
      block.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeBlock(UserBlock userBlock) async {
    return streamDatabase.delete(
      'block',
      where: 'blocking_user_id=? AND blocked_user_id=?',
      whereArgs: [userBlock.blockingUserId, userBlock.blockedUserId],
    );
  }

  Future<void> clearNewFeed() async {
    String searchModeString =searchModeToString(SearchModes.MINE);
    String notificationType= OutfitNotification.fromNotificationType(NotificationType.NEW_OUTFIT);
    await streamDatabase.executeAndTrigger(['user'], "UPDATE user SET has_new_feed_outfits=0 WHERE user_id=(SELECT search_user_id FROM user_search WHERE search_user_mode=? LIMIT 1)", [searchModeString]);
    return _markNotificationTypeAsSeen(notificationType);
  }

  Future<void> markWardrobeSeen(String userId){
    return streamDatabase.executeAndTrigger(['user'], "UPDATE user SET has_new_upload=0 WHERE user_id=?", [userId]);
  }

  Future<void> _markNotificationTypeAsSeen(String notificationType){
    return streamDatabase.query('notification', columns: ["COUNT(*) AS 'count'"], where: 'notification_is_seen=0 AND notification_type=?', whereArgs: [notificationType]).then(
      (res) {
        int count = res[0]['count'];
        incrementUserNewNotificationsCount(-count);
        return streamDatabase.executeAndTrigger(['notification'], "UPDATE notification SET notification_is_seen=1 WHERE notification_type=?", [notificationType]);
      }
    );
  }
}