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


  Future<bool> uploadOutfit(CreateOutfit createOutfit) async {
    return cloudFunctions.call(functionName: 'uploadOutfit', parameters: createOutfit.toJson())
    .then((res) async {

      int outfitId = res['ref'];      
      List<String> fileNames = _generateFileNames(createOutfit.images, outfitId, createOutfit);
      await imageUploader.uploadImages(createOutfit.images, fileNames);

      return true;
    })
    .catchError((err) {
      print(err);
      return false;
    });
  }

  _generateFileNames(List<String> imagePaths, int outfitId, CreateOutfit createOutfit){
    List<String> imageFiles = [];
    for(int i = 0; i < imagePaths.length; i++){
      final String uuid = Uuid().generateV4();
      imageFiles.add('$tempOutfitImagesFolder/$outfitId:${createOutfit.posterUserId}:${i+1}:${uuid.toString()}${extension(imagePaths[i])}');
    }
    return imageFiles;
  }
}