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

  Future<int> deleteOutfit(Outfit outfitToDelete) async {
    return streamDatabase.delete(
      'outfit',
      where: 'outfit_id = ?',
      whereArgs: [outfitToDelete.outfit_id],
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
      outfit.toJson(cache: true),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearOutfits() async {
    await streamDatabase.execute("DELETE FROM outfit");
  }

  Stream<Outfit> getOutfit(int outfitId){
    return streamDatabase.createRawQuery(['outfit'], 'SELECT * FROM outfit, user WHERE user_id = poster_user_id AND outfit_id=$outfitId LIMIT 1').mapToOneOrDefault((data) {
      return Outfit.fromMap(data);
    }, null).asBroadcastStream();
  }

  Stream<List<Outfit>> getOutfits(){
    return streamDatabase.createRawQuery(['outfit'], 'SELECT * FROM outfit, user WHERE user_id = poster_user_id ORDER BY outfit_created_at desc').mapToList((data) {
      return Outfit.fromMap(data);
    }).asBroadcastStream();
  }
}
