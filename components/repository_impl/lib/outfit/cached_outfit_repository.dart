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
      outfit.toJson(cache: true),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearOutfits() async {
    await streamDatabase.execute("DELETE FROM outfit");
  }

  Stream<List<Outfit>> getOutfits(){
    return streamDatabase.createRawQuery(['outfit'], 'SELECT * FROM outfit, user WHERE user_id = poster_user_id ORDER BY outfit_created_at desc').mapToList((data) {
      return Outfit.fromMap(data);
    }).asBroadcastStream();
  }
}
