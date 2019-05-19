import 'package:cloud_functions/cloud_functions.dart';
import 'package:middleware/middleware.dart';
import 'package:repository_impl/repository_impl.dart';
import 'package:meta/meta.dart';

class FirebaseOutfitRepository implements OutfitRepository {
  static const String dbPath = 'posts';

  final int numberOfPosts = 15;

  final CloudFunctions cloudFunctions;
  final FirebaseImageUploader imageUploader;
  // final CachedOutfitRepository cache;

  const FirebaseOutfitRepository({
    @required this.cloudFunctions,
    @required this.imageUploader,
    // @required this.cache
  });
  Future<List<Outfit>> getOutfits() {
    return cloudFunctions.call(functionName: 'exploreOutfits', parameters: {
      'poster_user_id' : '0123456789',
    })
    .then((res) async {
      // print('res:${res['res'][0]['outfit_created_at']}');
      List<Outfit> outfits = List<Outfit>.from(res['res'].map((data){
        Map<String, dynamic> formattedDoc = Map<String, dynamic>.from(data);
        return Outfit.fromMap(formattedDoc);
      }).toList());

      print('number of outfits: ${outfits.length}');
      return outfits;
    })
    .catchError((err) {
      print(err);
      return List<Outfit>();
    });
  }
}