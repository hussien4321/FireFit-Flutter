import '../local_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:middleware/middleware.dart';
import 'package:streamqflite/streamqflite.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

class CachedOutfitRepository {

  StreamDatabase _streamDatabase;

  CachedOutfitRepository({@required StreamDatabase streamDatabase}) {
    this._streamDatabase = streamDatabase;
  }

  // Future<void> addPosts(List<FashionPostEntity> posts) async {
  //   String insertString = "";
  //   if(posts.isNotEmpty){
  //     for(int i = 0; i < posts.length; i++){
  //       insertString += "(${posts[i].toSqlInsert()})${i != posts.length-1 ? ' ,' : ''}";
  //     }
  //     await _streamDatabase.executeAndTrigger(["posts"], "INSERT INTO posts VALUES $insertString");
  //   }
  // }

  // Future<void> clearPostsNoTrigger() async {
  //   await _streamDatabase.execute("DELETE FROM posts");
  // }

  // Future<void> clearPosts() async {
  //   await _streamDatabase.executeAndTrigger(["posts"], "DELETE FROM posts");
  // }

  // Future<void> savePost(FashionPostEntity newPost) async {
  //   await _streamDatabase.executeAndTrigger(["posts"], "INSERT INTO posts VALUES (${newPost.toSqlInsert()})");
  // }

  // Future<void> updatePost(FashionPostEntity updatedPost) async {
  //   await _streamDatabase.execute(_deleteQuery(updatedPost));
  //   await savePost(updatedPost);
  // }

  // Future<void> incrementUserPosts(String userId) async {
  //   await _streamDatabase.executeAndTrigger(["users"], "UPDATE users SET number_of_posts = number_of_posts + 1 WHERE user_id='$userId'");
  // }
  // Future<void> decrementUserPosts(String userId) async {
  //   await _streamDatabase.executeAndTrigger(["users"], "UPDATE users SET number_of_posts = number_of_posts - 1 WHERE user_id='$userId'");
  // }

  // String _deleteQuery(FashionPostEntity postToDelete) =>
  //   "DELETE FROM posts WHERE document_id='${postToDelete.posterData.documentId}' AND post_upload_date_time='${postToDelete.postUploadDateTime}'";

  // Future<void> deletePost(FashionPostEntity postToDelete) async {
  //   await _streamDatabase.executeAndTrigger(["posts"], _deleteQuery(postToDelete));
  // }


  // Stream<List<FashionPostEntity>> getPosts(){
  //   return _streamDatabase.createQuery('posts', orderBy: 'post_upload_date_time desc', ).mapToList((data) {
  //     return FashionPostEntity.fromSQLMap(data);
  //   }).asBroadcastStream();
  // }
}
