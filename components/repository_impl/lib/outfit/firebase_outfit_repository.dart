import 'package:cloud_functions/cloud_functions.dart';
import 'package:middleware/middleware.dart';
import 'package:repository_impl/repository_impl.dart';
import 'package:meta/meta.dart';
import 'package:helpers/helpers.dart';
import 'package:path/path.dart';

class FirebaseOutfitRepository implements OutfitRepository {

  final String tempOutfitImagesFolder = 'temp';
  
  final int numberOfPosts = 15;

  final CloudFunctions cloudFunctions;
  final FirebaseImageUploader imageUploader;
  final CachedOutfitRepository cache;

  const FirebaseOutfitRepository({
    @required this.cloudFunctions,
    @required this.imageUploader,
    @required this.cache
  });

  Stream<List<Outfit>> getOutfits() => cache.getOutfits();

  Future<bool> exploreOutfits() async {
    await cache.clearOutfits();
    return exploreMoreOutfits();
  }
  
  Future<bool> exploreMoreOutfits() {
    return cloudFunctions.call(functionName: 'exploreOutfits', parameters: {
      'poster_user_id' : '0123456789',
    })
    .then((res) async {
      List<Outfit> outfits = List<Outfit>.from(res['res'].map((data){
        Map<String, dynamic> formattedDoc = Map<String, dynamic>.from(data);
        print("loading user data ${formattedDoc['user_id']}");
        return Outfit.fromMap(formattedDoc);
      }).toList());

      outfits.forEach((outfit) => cache.addOutfit(outfit));
      
      return true;
    })
    .catchError((err) {
      print(err);
      return false;
    });
  }


  Future<bool> uploadOutfit(UploadOutfit uploadOutfit) async {
    return cloudFunctions.call(functionName: 'uploadOutfit', parameters: uploadOutfit.toJson())
    .then((res) async {

      int outfitId = res['ref'];      
      List<String> fileNames = _generateFileNames(uploadOutfit.images, outfitId, uploadOutfit);
      await imageUploader.uploadImages(uploadOutfit.images, fileNames);

      return true;
    })
    .catchError((err) {
      print(err);
      return false;
    });
  }

  _generateFileNames(List<String> imagePaths, int outfitId, UploadOutfit uploadOutfit){
    List<String> imageFiles = [];
    for(int i = 0; i < imagePaths.length; i++){
      final String uuid = Uuid().generateV4();
      imageFiles.add('$tempOutfitImagesFolder/$outfitId:${uploadOutfit.posterUserId}:${i+1}:${uuid.toString()}${extension(imagePaths[i])}');
    }
    return imageFiles;
  }

  
  Future<bool> deleteOutfit(Outfit outfit) async {
    cache.deleteOutfit(outfit);
    return cloudFunctions.call(functionName: 'deleteOutfit', parameters: {
      'poster_user_id' : '0123456789',
      'outfit_id': outfit.toJson()['outfit_id']
    })
    .then((res) async {
      bool status = res['res'];
      return status;
    })
    .catchError((err) {
      print(err);
      return false;
    });
  }

}