import 'package:sqflite/sqflite.dart';
import 'package:middleware/middleware.dart';
import 'package:streamqflite/streamqflite.dart';
import 'package:meta/meta.dart';

class CachedUserRepository {

  StreamDatabase streamDatabase;

  CachedUserRepository({@required this.streamDatabase});

  addUser(User user) {
    return streamDatabase.insert(
      'user',
      user.toJson(cache: true),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<User> getUser(String userId){
    return streamDatabase.createQuery('user', where: 'user_id = $userId', ).mapToOne((data) {
      return User.fromMap(data);
    }).first;
  }
}
