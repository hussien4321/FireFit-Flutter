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
    addOutfitSearch(outfit.outfitId, searchMode);
    await userCache.addUser(outfit.poster, searchMode);
    if(searchMode==SearchModes.SAVED){
      await _addOutfitSave(outfit.save);
    }
    return _addOutfit(outfit, searchMode);
  }

  Future<int> _addOutfit(Outfit outfit, SearchModes searchMode){
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace;
    if(searchMode ==SearchModes.NOTIFICATIONS){
      conflictAlgorithm =ConflictAlgorithm.ignore;
    }
    return streamDatabase.insert(
      'outfit',
      outfit.toJson(),
      conflictAlgorithm: conflictAlgorithm,
    );
  }
  
  Future<int> addLookbook(Lookbook lookbook){
    _incrementLookbookCount(lookbook);
      return streamDatabase.insert(
      'lookbook',
      lookbook.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  

  Future<int> addOutfitSearch(int outfitId, SearchModes searchMode) async {
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


  Future<void> _addOutfitSave(Save save) async {
    if(save.saveId!=null){
      return streamDatabase.insert(
        'save',
        save.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<int> deleteOutfit(Outfit outfitToDelete) async {
    await _decrementOutfitCount(outfitToDelete.poster.userId);
    return streamDatabase.delete(
      'outfit',
      where: 'outfit_id = ?',
      whereArgs: [outfitToDelete.outfitId],
    );
  }
  Future<int> deleteSave(DeleteSave deleteSave) async {
    await _deleteOutfitSearch(deleteSave.save.outfitId, SearchModes.SAVED);
    await _decrementLookbookOutfitsCount(deleteSave.save.lookbookId, deleteSave.userId);
    return streamDatabase.delete(
      'save',
      where: 'save_id=?',
      whereArgs: [deleteSave.save.saveId],
    );
  }
  Future<int> _deleteOutfitSearch(int outfitId, SearchModes searchMode) async {
    return streamDatabase.delete(
      'outfit_search',
      where: 'search_outfit_id = ? AND search_outfit_mode = ?',
      whereArgs: [outfitId, searchModeToString(searchMode)],
    );
  }

  Future<int> _deleteSavesFromLookbook(int lookbookId) async {
    return streamDatabase.delete(
      'save',
      where: 'save_lookbook_id=?',
      whereArgs: [lookbookId],
    );
  }
  Future<void> deleteLookbook(Lookbook lookbook) async {
    await streamDatabase.delete(
      'lookbook',
      where: 'lookbook_id=?',
      whereArgs: [lookbook.lookbookId],
    );
    await _deleteSavesFromLookbook(lookbook.lookbookId);
    return _decrementLookbookCount(lookbook);
  }

  Future<int> deleteComment(DeleteComment deleteComment) async {
    _decrementCommentsCount(deleteComment.outfitId, deleteComment.comment.repliesCount);
    if(deleteComment.comment.replyTo!=null){
      _decrementCommentReplyCount(deleteComment.comment.replyTo);
    }
    return streamDatabase.delete(
      'comment',
      where: 'comment_id = ?',
      whereArgs: [deleteComment.comment.commentId],
    );
  }

  Future<void> saveOutfit(OutfitSave saveData) async {
    Outfit outfit = saveData.outfit;
    await addOutfit(outfit, SearchModes.SAVED);
  }

  Future<void> addSave(OutfitSave saveData, int saveId) async {
    Save save =Save(
      lookbookId: saveData.lookbookId,
      outfitId: saveData.outfit.outfitId,
      createdAt: DateTime.now(),
      saveId: saveId
    );
    saveData.outfit.save = save;
    await addOutfit(saveData.outfit, SearchModes.SAVED);
    return _incrementLookbookOutfitsCount(saveData.lookbookId, saveData.userId);
  }

  Future<void> editOutfit(EditOutfit editOutfit) {
    return streamDatabase.executeAndTrigger(['outfit'], "UPDATE outfit SET style=?, title=?, description=? WHERE outfit_id=?", [editOutfit.style, editOutfit.title, editOutfit.description, editOutfit.outfitId]);
  }

  Future<void> editLookbook(EditLookbook editLookbook) async {
    await streamDatabase.executeAndTrigger(['lookbook'], "UPDATE lookbook SET lookbook_name=? WHERE lookbook_id=?", [editLookbook.name, editLookbook.lookbookId]);
    return streamDatabase.executeAndTrigger(['lookbook'], "UPDATE lookbook SET lookbook_description=? WHERE lookbook_id=?", [editLookbook.description, editLookbook.lookbookId]);
  }

  Future<int> rateOutfit(OutfitRating outfitRating) async {
    Outfit outfit = outfitRating.outfit;
    int ratingValue = outfitRating.ratingValue;
    double average = outfit.trueAverageRating;
    double total = outfit.ratingsCount.toDouble();
    if(outfit.hasRating){
      average = total == 1 ? 0 : ((average * total) - outfit.userRating) / (total - 1);
      total--;
      userCache.incrementFlamesCount(outfit.poster.userId, outfit.userRating, decrement: true);
    }
    outfit.averageRating = ((average*total.toDouble()) + ratingValue) / (total + 1);
    outfit.userRating = ratingValue;
    outfit.ratingsCount =(total+1).toInt();
    userCache.incrementFlamesCount(outfit.poster.userId, ratingValue);
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
    if(searchMode!=SearchModes.MINE && searchMode!=SearchModes.SELECTED){
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

  Future<void> _clearOutfitSearchesForOutfit(SearchModes searchMode, Outfit outfit) async {
    String searchModeString = searchModeToString(searchMode);
    await streamDatabase.execute("DELETE FROM outfit_search WHERE search_outfit_mode=? AND search_outfit_id=?", [searchModeString, outfit.outfitId]);
  }
  Future<void> clearLookbooks() async {
    await streamDatabase.executeAndTrigger(['lookbook'], "DELETE FROM lookbook");
  }

  Future<void> clearComments() async {
    await streamDatabase.executeAndTrigger(['comment'], "DELETE FROM comment");
    await userCache.clearUsers(SearchModes.TEMP);
  }

  Stream<Outfit> getOutfit(SearchModes searchMode){
    String searchModeString = searchModeToString(searchMode);
    return streamDatabase.createRawQuery(['outfit', 'outfit_search'], "SELECT * FROM outfit, user WHERE user_id = poster_user_id AND (SELECT COUNT(*) FROM outfit_search WHERE search_outfit_id=outfit_id AND search_outfit_mode=?)=1 LIMIT 1", [searchModeString]).mapToOneOrDefault((data) {
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
        queryStream = streamDatabase.createRawQuery(['outfit', 'save'], 'SELECT * FROM outfit LEFT JOIN user ON poster_user_id=user_id LEFT JOIN outfit_search ON outfit_id=search_outfit_id LEFT JOIN save ON outfit_id=save_outfit_id WHERE search_outfit_mode=? ORDER BY save_created_at desc', [searchModeString]);
        break;
      default:
        break;
    }
    return queryStream.mapToList((data) {
      return Outfit.fromMap(data);
    }).asBroadcastStream();
  }

  Stream<List<Lookbook>> getLookbooks(){
    return streamDatabase.createRawQuery(['lookbook'], 'SELECT * FROM lookbook ORDER BY lookbook_created_at desc')
    .mapToList((data) {
      return Lookbook.fromMap(data);
    }).asBroadcastStream();
  }


  Future<void> _incrementOutfitLikes(Outfit outfit) async {
    return streamDatabase.executeAndTrigger(['outfit'], "UPDATE outfit SET likes_count=likes_count+1 WHERE outfit_id=?", [outfit.outfitId]);
  }
  
  Future<void> _incrementLookbookCount(Lookbook lookbook) async {
    return streamDatabase.executeAndTrigger(['user'], "UPDATE user SET number_of_lookbooks=number_of_lookbooks+1 WHERE user_id=?", [lookbook.userId]);
  }
  Future<void> _decrementLookbookCount(Lookbook lookbook) async {
    // print('userId:${lookbook.userId} numberOfOutfits:${lookbook.numberOfOutfits}');
    await streamDatabase.executeAndTrigger(['user'], "UPDATE user SET number_of_lookbooks=number_of_lookbooks-1 WHERE user_id=?", [lookbook.userId]);
    return streamDatabase.executeAndTrigger(['user'], "UPDATE user SET number_of_lookbook_outfits=number_of_lookbook_outfits-${lookbook.numberOfOutfits} WHERE user_id=?", [lookbook.userId]);
  }

  Future<void> _incrementLookbookOutfitsCount(int lookbookId, String userId) async {
    await streamDatabase.executeAndTrigger(['user'], "UPDATE user SET number_of_lookbook_outfits=number_of_lookbook_outfits+1 WHERE user_id=?", [userId]);
    return streamDatabase.executeAndTrigger(['lookbook'], "UPDATE lookbook SET number_of_outfits=number_of_outfits+1 WHERE lookbook_id=?", [lookbookId]);
  }
  Future<void> _decrementLookbookOutfitsCount(int lookbookId, String userId) async {
    await streamDatabase.executeAndTrigger(['user', ], "UPDATE user SET number_of_lookbook_outfits=number_of_lookbook_outfits-1 WHERE user_id=?", [userId]);
    return streamDatabase.executeAndTrigger(['lookbook', 'outfit', 'save'], "UPDATE lookbook SET number_of_outfits=number_of_outfits-1 WHERE lookbook_id=?", [lookbookId]);
  }

  Future<void> _incrementCommentReplyCount(int commentId) {
    return streamDatabase.executeAndTrigger(['comment'], "UPDATE comment SET comment_replies_count=comment_replies_count+1 WHERE comment_id=?", [commentId]);
  }

  Future<void> _decrementCommentReplyCount(int commentId) {
    return streamDatabase.executeAndTrigger(['comment'], "UPDATE comment SET comment_replies_count=comment_replies_count-1 WHERE comment_id=?", [commentId]);
  }

  Future<void> _incrementCommentsCount(int outfitId) async {
    return streamDatabase.executeAndTrigger(['outfit'], "UPDATE outfit SET comments_count=comments_count+1 WHERE outfit_id=?", [outfitId]);
  }
  Future<void> _decrementCommentsCount(int outfitId, int numReplies) async {
    int diff = numReplies + 1; 
    return streamDatabase.executeAndTrigger(['outfit'], "UPDATE outfit SET comments_count=comments_count-? WHERE outfit_id=?", [diff, outfitId]);
  }
  
  Future<void> _incrementCommentLikesCount(Comment comment) async {
    return streamDatabase.executeAndTrigger(['comment'], "UPDATE comment SET comment_likes_count=comment_likes_count+1 WHERE comment_id=?", [comment.commentId]);
  }
  
  Future<int> addNewComment(AddComment addComment, int tempCommentId) async {
    Map<String, dynamic> newComment = {
      'comment_id' : tempCommentId, 
      'commenter_user_id': addComment.userId,
      'comment_body': addComment.commentText,
      'comment_likes_count': 0,
      'comment_is_liked': 0,
      'comment_reply_to': addComment.replyingToComment?.commentId,
      'comment_replies_count': 0,
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
  Future<void> updateComment(AddComment addComment, int tempCommentId, int actualCommentId) async { 
    await streamDatabase.rawUpdate(['comment'], 'UPDATE comment SET comment_id=? WHERE comment_id=?', [actualCommentId, tempCommentId]);
    if(addComment.replyingToComment != null){
      await _incrementCommentReplyCount(addComment.replyingToComment.commentId);
    }
    return _incrementCommentsCount(addComment.outfit.outfitId);
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
      //TODO: ADD A COMMENT SEARCH AS WELL
      // await _addComment(notification.referencedComment.toJson());
    }
    return streamDatabase.insert(
      'notification',
      notification.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateLiveNotification(OutfitNotification notification) async { 
    if(notification.type == NotificationType.NEW_OUTFIT){
      await userCache.updateUserHasNewFeed();
    }
  }

  Future<DateTime> getLatestNotificationTime() async {
    return streamDatabase.query('notification', columns: ['notification_created_at'], orderBy: 'notification_created_at DESC', limit: 1).then(
      (res) {
        if (res.isEmpty) {
          return null;
        }
        return DateTime.parse(res[0]['notification_created_at']);
      }
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
  Future<void> _decrementOutfitCount(String userId){
    return streamDatabase.executeAndTrigger(['user'], "UPDATE user SET number_of_outfits=number_of_outfits-1 WHERE user_id=?", [userId]);
  }
}
