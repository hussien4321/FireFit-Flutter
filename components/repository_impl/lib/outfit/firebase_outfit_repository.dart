import 'package:cloud_functions/cloud_functions.dart';
import 'package:middleware/middleware.dart';
import 'package:repository_impl/repository_impl.dart';
import 'package:meta/meta.dart';
import 'package:helpers/helpers.dart';
import 'package:path/path.dart';
import 'dart:math';

class FirebaseOutfitRepository implements OutfitRepository {

  
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

  Stream<Outfit> getOutfit(int outfitId) => cache.getOutfit(outfitId);


  Future<bool> loadOutfits(OutfitsSearch outfitsSearch) async {
    await cache.clearOutfits();
    return loadMoreOutfits(outfitsSearch);
  }
  
  Future<bool> loadMoreOutfits(OutfitsSearch outfitsSearch) {
    return cloudFunctions.call(functionName: 'getOutfits', parameters: outfitsSearch.toJson())
    .then((res) async {
      _saveOutfitsList(res);
      return true;
    })
    .catchError((err) => false);
  }

  _saveOutfitsList(dynamic response){
    List<Outfit> outfits = List<Outfit>.from(response['res'].map((data){
      Map<String, dynamic> formattedDoc = Map<String, dynamic>.from(data);
      return Outfit.fromMap(formattedDoc);
    }).toList());
    outfits.forEach((outfit) => cache.addOutfit(outfit));
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
      imageFiles.add('temp/outfit:$outfitId:${uploadOutfit.posterUserId}:${i+1}:${uuid.toString()}${extension(imagePaths[i])}');
    }
    return imageFiles;
  }

  
  
  Future<bool> deleteOutfit(Outfit outfit) async {
    cache.deleteOutfit(outfit);
    return cloudFunctions.call(functionName: 'deleteOutfit', parameters: {
      'poster_user_id' : outfit.poster.userId,
      'outfit_id': outfit.outfit_id
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

  Future<bool> saveOutfit(OutfitSave saveData) async {
    cache.saveOutfit(saveData);
    return cloudFunctions.call(functionName: 'saveOutfit', parameters: saveData.toJson())
    .then((res) async {
      bool status = res['res'];
      return status;
    })
    .catchError((err) {
      print(err);
      return false;
    });
  }

  Future<bool> impressOutfit(OutfitImpression outfitImpression) async {
    cache.impressOutfit(outfitImpression);
    return cloudFunctions.call(functionName: 'impressOutfit', parameters: outfitImpression.toJson())
    .then((res) async {
      bool status = res['res'];
      return status;
    })
    .catchError((err) {
      print(err);
      return false;
    });
  }
  Future<bool> addComment(AddComment addComment) async {
    Random tempIdGenerator =new Random();
    int tempCommentId =tempIdGenerator.nextInt(1000000) * -1;
    cache.addComment(addComment, tempCommentId);

    return cloudFunctions.call(functionName: 'addComment', parameters: addComment.toJson())
    .then((res) async {
      int actualCommentId = res['res'];
      await cache.updateComment(addComment, tempCommentId ,actualCommentId);
      return true;
    })
    .catchError((err) {
      print(err.message);
      return false;
    });
  }


  Future<bool> likeComment(CommentLike commentlike) async {
    cache.likeComment(commentlike);
    return cloudFunctions.call(functionName: 'likeComment', parameters: commentlike.toJson())
    .then((res) async {
      bool status = res['res'];
      return status;
    })
    .catchError((err) {
      print(err);
      return false;
    });
  }

  
  Stream<List<Comment>> getComments() => cache.getComments();

  Future<bool> loadComments(LoadComments loadComments) async {
    await cache.clearComments();
    return loadMoreComments(loadComments);
  }

  Future<bool> loadMoreComments(LoadComments loadComments) async {
    return cloudFunctions.call(functionName: 'loadComments', parameters: loadComments.toJson())
    .then((res) async {
      _saveCommentsList(res);
      return true;
    })
    .catchError((err) {
      print(err);
      return false;
    });
  }

  _saveCommentsList(dynamic response){
    List<Comment> comments = List<Comment>.from(response['res'].map((data){
      Map<String, dynamic> formattedDoc = Map<String, dynamic>.from(data);
      return Comment.fromMap(formattedDoc);
    }).toList());
    comments.forEach((comment) => cache.insertComment(comment));
  }


}