import 'package:sqflite/sqflite.dart';
import 'package:middleware/middleware.dart';
import 'package:streamqflite/streamqflite.dart';
import 'package:meta/meta.dart';

class CachedUserRepository {

  StreamDatabase streamDatabase;

  CachedUserRepository({@required this.streamDatabase});

  addUser(User user) {
    print("ADDING USER WITH ID: ${user.userId}");
    return streamDatabase.insert(
      'user',
      user.toJson(cache: true),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Stream<User> getUser(String userId){
  return streamDatabase.createQuery('user', where: 'user_id = $userId', limit: 1).mapToOneOrDefault((data) {
      return User.fromMap(data);
    }, null).asBroadcastStream();
  }

  
  Future<void> deleteAll() async {
    await streamDatabase.executeAndTrigger(["user"], "DELETE FROM user");
  }
}