import 'package:sqflite/sqflite.dart';
import 'package:middleware/middleware.dart';
import 'package:streamqflite/streamqflite.dart';
import 'package:repository_impl/repository_impl.dart';
import 'package:meta/meta.dart';

class CachedOutfitRepository {

  StreamDatabase streamDatabase;
  CachedUserRepository userCache;

  CachedOutfitRepository({@required this.streamDatabase, @required this.userCache});

  Future<int> addOutfit(Outfit outfit) async {
    await userCache.addUser(outfit.poster);
    return streamDatabase.insert(
      'outfit',
      outfit.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteOutfit(Outfit outfitToDelete) async {
    return streamDatabase.delete(
      'outfit',
      where: 'outfit_id = ?',
      whereArgs: [outfitToDelete.outfit_id],
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
  

  Future<void> clearOutfits() async {
    await streamDatabase.executeAndTrigger(['outfit'],"DELETE FROM outfit");
  }

  Future<void> clearComments() async {
    await streamDatabase.executeAndTrigger(['comment'], "DELETE FROM comment");
  }

  Stream<Outfit> getOutfit(int outfitId){
    return streamDatabase.createRawQuery(['outfit'], "SELECT * FROM outfit, user WHERE user_id = poster_user_id AND outfit_id=$outfitId LIMIT 1").mapToOneOrDefault((data) {
      return Outfit.fromMap(data);
    }, null).asBroadcastStream();
  }

  Stream<List<Outfit>> getOutfits(){
    return streamDatabase.createRawQuery(['outfit'], 'SELECT * FROM outfit, user WHERE user_id = poster_user_id ORDER BY outfit_created_at desc').mapToList((data) {
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
  
  Future<int> addComment(AddComment addComment, int tempCommentId) async { 
    return streamDatabase.insert(
      'comment',
      {
        'comment_id' : tempCommentId, 
        'commenter_user_id': addComment.userId,
        'comment_body': addComment.commentText,
        'comment_likes_count': 0,
        'comment_is_liked': 0,
        'comment_created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<int> updateComment(AddComment addComment, int tempCommentId, int actualCommentId) async { 
    await streamDatabase.rawDelete([], 'DELETE FROM comment WHERE comment_id=$tempCommentId');
    _incrementCommentCount(addComment);
    return streamDatabase.insert(
      'comment',
      {
        'comment_id' : actualCommentId,
        'commenter_user_id': addComment.userId,
        'comment_body': addComment.commentText,
        'comment_likes_count': 0,
        'comment_is_liked': 0,
        'comment_created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<int> insertComment(Comment comment) async { 
    await userCache.addUser(comment.commenter);
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
    return streamDatabase.createRawQuery(['comment'], 'SELECT * FROM comment, user WHERE user_id = commenter_user_id ORDER BY comment_created_at desc').mapToList((data) {
      return Comment.fromMap(data);
    }).asBroadcastStream();
  }  
  
  Future<int> insertNotification(OutfitNotification notification) async { 
    await userCache.addUser(notification.referencedUser);
    addOutfit(notification.referencedOutfit);
    return streamDatabase.insert(
      'notification',
      notification.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearNotifications() async {
    await streamDatabase.executeAndTrigger(['notification'], "DELETE FROM notification");
  }
  
  Stream<List<OutfitNotification>> getNotifications(){
    return streamDatabase.createRawQuery(['notification'], 'SELECT * FROM notification, outfit, user WHERE user_id = poster_user_id AND notification_reference_id = outfit_id ORDER BY notification_created_at desc').mapToList((data) {
      return OutfitNotification.fromMap(data);
    }).asBroadcastStream();
  }
}
