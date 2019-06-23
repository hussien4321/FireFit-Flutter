import 'package:cloud_functions/cloud_functions.dart';
import 'package:middleware/middleware.dart';
import 'package:repository_impl/repository_impl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:meta/meta.dart';
import 'package:helpers/helpers.dart';
import 'package:path/path.dart';
import 'dart:math';
import 'dart:async';

class FirebaseOutfitRepository implements OutfitRepository {
  
  final int numberOfPosts = 15;

  final CloudFunctions cloudFunctions;
  final FirebaseImageUploader imageUploader;
  final CachedOutfitRepository cache;

  const FirebaseOutfitRepository({
    @required this.cloudFunctions,
    @required this.imageUploader,
    @required this.cache,
  });

  Stream<List<Outfit>> getOutfits(SearchModes searchMode) => cache.getOutfits(searchMode);

  Stream<Outfit> getOutfit(int outfitId) => cache.getOutfit(outfitId);


  Future<bool> loadOutfits(LoadOutfits loadOutfits) async {
    await cache.clearOutfits(loadOutfits.searchMode);
    return loadMoreOutfits(loadOutfits);
  }
  
  Future<bool> loadMoreOutfits(LoadOutfits loadOutfits) {
    return cloudFunctions.getHttpsCallable(functionName: 'getOutfits').call(loadOutfits.toJson())
    .then((res) async {
      List<Outfit> outfits = _resToOutfitList(res);
      outfits.forEach((outfit) => cache.addOutfit(outfit, loadOutfits.searchMode));
      return true;
    })
    .catchError((err) => false);
  }

  List<Outfit> _resToOutfitList(HttpsCallableResult res){
    return List<Outfit>.from(res.data['res'].map((data){
      Map<String, dynamic> formattedDoc = Map<String, dynamic>.from(data);
      return Outfit.fromMap(formattedDoc);
    }).toList());
  }

  Future<bool> uploadOutfit(UploadOutfit uploadOutfit) async {
    return cloudFunctions.getHttpsCallable(functionName: 'uploadOutfit').call(uploadOutfit.toJson())
    .then((res) async {
      int outfitId = res.data['ref'];      
      List<String> fileNames = _generateFileNames(uploadOutfit.images, outfitId, uploadOutfit);
      await imageUploader.uploadImages(uploadOutfit.images, fileNames);

      return _checkOutfitImageUploaded(outfitId, uploadOutfit.posterUserId);
    })
    .catchError((err) {
      print(err.message);
      return false;
    });
  }

  _generateFileNames(List<String> imagePaths, int outfitId, UploadOutfit uploadOutfit){
    List<String> imageFiles = [];
    for(int i = 0; i < imagePaths.length; i++){
      final String uuid = Uuid().generateV4();
      imageFiles.add('temp/outfit:$outfitId:${uploadOutfit.posterUserId}:${i+1}:${imagePaths.length}:${uuid.toString()}${extension(imagePaths[i])}');
    }
    return imageFiles;
  }

  Future<bool> _checkOutfitImageUploaded(int outfitId, String userId) async {
    LoadOutfit loadOutfit = LoadOutfit(
      outfitId: outfitId,
      userId: userId,
    );
    for(int i = 0; i < AppConfig.NUMBER_OF_POLL_ATTEMPTS; i++){
      print('polling for outfit attempt:$i time=${DateTime.now()}');
      bool success = await _getUploadedOutfit(loadOutfit);
      if(success){
        return true;
      }
      await Future.delayed(Duration(milliseconds: AppConfig.DURATION_PER_POLL_ATTEMPT));
    }
    return false;
  }

  Future<bool> _getUploadedOutfit(LoadOutfit loadOutfit) {
    return cloudFunctions.getHttpsCallable(functionName: 'getOutfit').call(loadOutfit.toJson())
    .then((res) async {
      List<Outfit> outfits = _resToOutfitList(res);
      if(outfits.isEmpty){
        return false;
      }
      Outfit newOutfit = outfits.first;
      await cache.addOutfit(newOutfit, SearchModes.MINE);
      await cache.incrementOutfitCount(loadOutfit.userId);
      return true;
    })
    .catchError((err) => false);
  }

  Future<bool> editOutfit(EditOutfit editOutfit) async {
    cache.editOutfit(editOutfit);
    return cloudFunctions.getHttpsCallable(functionName: 'editOutfit').call(editOutfit.toJson())
    .then((res) async {
      bool status = res.data['res'];
      return status;
    })
    .catchError((err) {
      print(err.message);
      return false;
    });
  }


  
  Future<bool> deleteOutfit(Outfit outfit) async {
    cache.deleteOutfit(outfit);
    return cloudFunctions.getHttpsCallable(functionName: 'deleteOutfit').call({
      'poster_user_id' : outfit.poster.userId,
      'outfit_id': outfit.outfitId
    })
    .then((res) async {
      bool status = res.data['res'];
      return status;
    })
    .catchError((err) {
      print(err);
      return false;
    });
  }

  Future<bool> saveOutfit(OutfitSave saveData) async {
    cache.saveOutfit(saveData);
    return cloudFunctions.getHttpsCallable(functionName: 'saveOutfit').call(saveData.toJson())
    .then((res) async {
      bool status = res.data['res'];
      return status;
    })
    .catchError((err) {
      print(err);
      return false;
    });
  }

  Future<bool> impressOutfit(OutfitImpression outfitImpression) async {
    cache.impressOutfit(outfitImpression);
    return cloudFunctions.getHttpsCallable(functionName: 'impressOutfit').call(outfitImpression.toJson())
    .then((res) async {
      bool status = res.data['res'];
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
    cache.addNewComment(addComment, tempCommentId);

    return cloudFunctions.getHttpsCallable(functionName: 'addComment').call(addComment.toJson())
    .then((res) async {
      int actualCommentId = res.data['res'];
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
    return cloudFunctions.getHttpsCallable(functionName: 'likeComment').call(commentlike.toJson())
    .then((res) async {
      bool status = res.data['res'];
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
    return cloudFunctions.getHttpsCallable(functionName: 'loadComments').call(loadComments.toJson())
    .then((res) async {
      _saveCommentsList(res.data);
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
    comments.forEach((comment) => cache.addComment(comment));
  }

  Future<bool> deleteComment(DeleteComment deleteComment) async {
    cache.deleteComment(deleteComment);
    return cloudFunctions.getHttpsCallable(functionName: 'deleteComment').call(deleteComment.toJson())
    .then((res) async {
      bool status = res.data['res'];
      return status;
    })
    .catchError((err) {
      print(err);
      return false;
    });
  }


}