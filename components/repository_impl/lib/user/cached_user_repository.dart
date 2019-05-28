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
      user.toJson(cache: true, isCurrentUser: isCurrentUser),
      conflictAlgorithm: isCurrentUser ? ConflictAlgorithm.replace : ConflictAlgorithm.ignore,
    );
  }
  
  Stream<User> getCurrentUser(){
  return streamDatabase.createQuery('user', where: "is_current_user = 1", limit: 1).mapToOneOrDefault((data) {
      return User.fromMap(data);
    }, null).asBroadcastStream();
  }

  
  Future<void> deleteAll() async {
    await streamDatabase.executeAndTrigger(["user"], "DELETE FROM user");
  }
}