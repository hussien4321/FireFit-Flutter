import 'package:sqflite/sqflite.dart';
import 'package:middleware/middleware.dart';
import 'package:streamqflite/streamqflite.dart';
import 'package:repository_impl/repository_impl.dart';
import 'package:meta/meta.dart';
import 'dart:async';

class CachedOutfitRepository {

  StreamDatabase streamDatabase;
  CachedUserRepository userCache;

  CachedOutfitRepository({@required this.streamDatabase, @required this.userCache});

  Future<int> addOutfit(Outfit outfit, SearchModes searchMode) async {
    _addOutfitSearch(outfit.outfitId, searchMode);
    await userCache.addUser(outfit.poster, searchMode);
    if(searchMode ==SearchModes.SAVED){
      await _addOutfitSave(outfit.save);
    }
    return streamDatabase.insert(
      'outfit',
      outfit.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> _addOutfitSearch(int outfitId, SearchModes searchMode) async {
    SearchOutfit searchOutfit =SearchOutfit(
      outfitId: outfitId,
      searchMode: searchModeToString(searchMode),
    );
    return streamDatabase.insert(
      'outfit_search',
      searchOutfit.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<int> _addOutfitSave(Save save) async {
    return streamDatabase.insert(
      'save',
      save.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteOutfit(Outfit outfitToDelete) async {
    return streamDatabase.delete(
      'outfit',
      where: 'outfit_id = ?',
      whereArgs: [outfitToDelete.outfitId],
    );
  }

  Future<int> saveOutfit(OutfitSave saveData) async {
    Outfit outfit = saveData.outfit;
    outfit.isSaved =!outfit.isSaved;
    return streamDatabase.insert(
      'outfit',
      outfit.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> impressOutfit(OutfitImpression outfitImpression) async {
    Outfit outfit = outfitImpression.outfit;
    int impressionValue = outfitImpression.impressionValue;
    if(outfit.userImpression == 1){
      outfit.likesCount--;
    }else if(outfit.userImpression == -1){
      outfit.dislikesCount--;
    }
    if(impressionValue == 1){
      outfit.likesCount++;
    }
    else if(impressionValue == -1){
      outfit.dislikesCount++;
    }
    outfit.userImpression = impressionValue;
    return streamDatabase.insert(
      'outfit',
      outfit.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  

  Future<void> clearAllOutfits() async {
    await streamDatabase.executeAndTrigger(['outfit'],"DELETE FROM outfit");
  }
  Future<void> clearOutfits(SearchModes searchMode) async {
    if(searchMode==SearchModes.SAVED){
      await _clearSaves();
    }
    if(searchMode==SearchModes.FEED){
      await userCache.clearNewFeed();
    }
    await _clearOutfitSearches(searchMode);
    await _clearOutfits(searchMode);
    if(searchMode!=SearchModes.MINE){
      await userCache.clearUsers(searchMode);
    }
  }
  Future<void> _clearSaves() async {
    await streamDatabase.executeAndTrigger(['save'], "DELETE FROM save");
  }
  Future<void> _clearOutfits(SearchModes searchMode) async {
    String searchModeString =searchModeToString(searchMode);
    await streamDatabase.executeAndTrigger(['outfit'],"DELETE FROM outfit WHERE (SELECT COUNT(*) FROM outfit_search WHERE search_outfit_id=outfit_id AND search_outfit_mode=?)=1 AND (SELECT COUNT(*) FROM outfit_search WHERE search_outfit_id=outfit_id AND search_outfit_mode!=?)=0", [searchModeString, searchModeString]);
  }
  Future<void> _clearOutfitSearches(SearchModes searchMode) async {
    String searchModeString = searchModeToString(searchMode);
    await streamDatabase.execute("DELETE FROM outfit_search WHERE search_outfit_mode=?", [searchModeString]);
  }

  Future<void> clearComments() async {
    await streamDatabase.executeAndTrigger(['comment'], "DELETE FROM comment");
    await userCache.clearUsers(SearchModes.TEMP);
  }

  Stream<Outfit> getOutfit(int outfitId){
    return streamDatabase.createRawQuery(['outfit'], "SELECT * FROM outfit, user WHERE user_id = poster_user_id AND outfit_id=? LIMIT 1", [outfitId]).mapToOneOrDefault((data) {
      return Outfit.fromMap(data);
    }, null).asBroadcastStream();
  }

  Stream<List<Outfit>> getOutfits(SearchModes searchMode){
    QueryStream queryStream;
    String searchModeString = searchModeToString(searchMode);
    switch (searchMode) {
      case SearchModes.EXPLORE:
      case SearchModes.MINE:
      case SearchModes.SELECTED:
      case SearchModes.FEED:
        queryStream = streamDatabase.createRawQuery(['outfit'], 'SELECT * FROM outfit LEFT JOIN user ON user_id=poster_user_id LEFT JOIN outfit_search ON outfit_id=search_outfit_id WHERE search_outfit_mode=? ORDER BY outfit_created_at desc', [searchModeString]);
        break;
      case SearchModes.SAVED:
        queryStream = streamDatabase.createRawQuery(['outfit'], 'SELECT * FROM outfit LEFT JOIN user ON poster_user_id=user_id LEFT JOIN outfit_search ON outfit_id=search_outfit_id LEFT JOIN save ON outfit_id=save_outfit_id WHERE is_saved=1 AND search_outfit_mode=? ORDER BY save_created_at desc', [searchModeString]);
        break;
      default:
        break;
    }
    return queryStream.mapToList((data) {
      return Outfit.fromMap(data);
    }).asBroadcastStream();
  }

  

  Future<int> _incrementCommentCount(AddComment addComment) async {
    Outfit outfit = addComment.outfit;
    outfit.commentsCount++;
    return streamDatabase.insert(
      'outfit',
      outfit.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<int> addNewComment(AddComment addComment, int tempCommentId) async {
    Map<String, dynamic> newComment = {
      'comment_id' : tempCommentId, 
      'commenter_user_id': addComment.userId,
      'comment_body': addComment.commentText,
      'comment_likes_count': 0,
      'comment_is_liked': 0,
      'comment_created_at': DateTime.now().toIso8601String(),
    };
    return _addComment(newComment);
  }
  Future<int> _addComment(Map<String, dynamic> commentMap) async {
    return streamDatabase.insert(
      'comment',
      commentMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<int> updateComment(AddComment addComment, int tempCommentId, int actualCommentId) async { 
    await streamDatabase.rawDelete([], 'DELETE FROM comment WHERE comment_id=$tempCommentId');
    _incrementCommentCount(addComment);
    return addNewComment(addComment, actualCommentId);
  }
  Future<int> addComment(Comment comment) async { 
    await userCache.addUser(comment.commenter, SearchModes.TEMP);
    return streamDatabase.insert(
      'comment',
      comment.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<int> likeComment(CommentLike commentlike) async {
    Comment modifiedComment = commentlike.comment;
    modifiedComment.likesCount += modifiedComment.isLiked ? -1 : 1;
    modifiedComment.isLiked=!modifiedComment.isLiked;
    return streamDatabase.insert(
      'comment',
      modifiedComment.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Stream<List<Comment>> getComments(){
    return streamDatabase.createRawQuery(['comment'], 'SELECT * FROM comment LEFT JOIN user ON commenter_user_id=user_id ORDER BY comment_created_at desc').mapToList((data) {
      return Comment.fromMap(data);
    }).asBroadcastStream();
  }  
  
  Future<int> addNotification(OutfitNotification notification) async { 
    if(notification.referencedUser != null){
      await userCache.addUser(notification.referencedUser, SearchModes.NOTIFICATIONS);
    }
    if(notification.referencedOutfit != null){
      await addOutfit(notification.referencedOutfit, SearchModes.NOTIFICATIONS);
    }
    if(notification.referencedComment != null){
      await _addComment(notification.referencedComment.toJson());
    }
    return streamDatabase.insert(
      'notification',
      notification.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearNotifications() async {
    await streamDatabase.executeAndTrigger(['notification'], "DELETE FROM notification");
    await clearOutfits(SearchModes.NOTIFICATIONS);
    await userCache.clearUsers(SearchModes.NOTIFICATIONS);
  }
  
  Stream<List<OutfitNotification>> getNotifications(){
    return streamDatabase.createRawQuery(['notification'], 'SELECT * FROM notification LEFT JOIN outfit ON notification_ref_outfit_id=outfit_id LEFT JOIN user ON notification_ref_user_id=user_id LEFT JOIN comment ON notification_ref_comment_id=comment_id ORDER BY notification_created_at desc').mapToList((data) {
      return OutfitNotification.fromMap(data);
    }).asBroadcastStream();
  }

  Future<void> incrementOutfitCount(String userId){
    return streamDatabase.executeAndTrigger(['user'], "UPDATE user SET number_of_outfits=number_of_outfits+1 WHERE user_id=?", [userId]);
  }
    

}
