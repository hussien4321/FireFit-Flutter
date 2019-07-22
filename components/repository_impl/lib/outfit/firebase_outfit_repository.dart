import 'package:cloud_functions/cloud_functions.dart';
import 'package:middleware/middleware.dart';
import 'package:repository_impl/repository_impl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:meta/meta.dart';
import 'package:helpers/helpers.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:repository_impl/exception_handler.dart';
import 'dart:math';
import 'dart:async';

class FirebaseOutfitRepository implements OutfitRepository {
  
  final int numberOfPosts = 15;

  final CloudFunctions cloudFunctions;
  final FirebaseImageUploader imageUploader;
  final CachedOutfitRepository cache;
  final FirebaseAnalytics analytics;

  const FirebaseOutfitRepository({
    @required this.cloudFunctions,
    @required this.imageUploader,
    @required this.cache,
    @required this.analytics,
  });

  Stream<List<Outfit>> getOutfits(SearchModes searchMode) => cache.getOutfits(searchMode);

  Stream<Outfit> getOutfit(SearchModes searchMode) => cache.getOutfit(searchMode);

  Stream<List<Lookbook>> getLookbooks() => cache.getLookbooks();

  Future<bool> loadOutfits(LoadOutfits loadOutfits) async {
    if(searchModesToNOTClearEachTime.every((sm) => sm!=loadOutfits.searchMode)){
      await cache.clearOutfits(loadOutfits.searchMode);
    }
    return loadMoreOutfits(loadOutfits);
  }
  

  Future<void> clearOutfits(SearchModes searchMode) => cache.clearOutfits(searchMode);

  Future<bool> loadMoreOutfits(LoadOutfits loadOutfits) async {
    return cloudFunctions.getHttpsCallable(functionName: 'getOutfits').call(loadOutfits.toJson())
    .then((res) async {
      List<Outfit> outfits = _resToOutfitList(res);
      outfits.forEach((outfit) => cache.addOutfit(outfit, loadOutfits.searchMode));
      return true;
    })
    .catchError((exception) => catchExceptionWithBool(exception, analytics));
  }


  Future<bool> loadLookbooks(LoadLookbooks loadLookbooks) async {
    return cloudFunctions.getHttpsCallable(functionName: 'getLookbooks').call(loadLookbooks.toJson())
    .then((res) async {
      List<Lookbook> lookbooks = _resToLookbookList(res);
      lookbooks.forEach((lookbook) => cache.addLookbook(lookbook));
      return true;
    })
    .catchError((exception) => catchExceptionWithBool(exception, analytics));
  }

  Future<bool> loadOutfit(LoadOutfit loadOutfit) async {
    await cache.clearOutfits(loadOutfit.searchModes);
    if(loadOutfit.loadFromCloud){
      return cloudFunctions.getHttpsCallable(functionName: 'getOutfit').call(loadOutfit.toJson())
      .then((res) async {
        List<Outfit> outfits = _resToOutfitList(res);
        outfits.forEach((outfit) => cache.addOutfit(outfit, loadOutfit.searchModes));
        return true;
      })
      .catchError((exception) => catchExceptionWithBool(exception, analytics));
    }else{
      cache.addOutfitSearch(loadOutfit.outfitId, loadOutfit.searchModes);
      return true;
    }
  }

  List<Outfit> _resToOutfitList(HttpsCallableResult res){
    return List<Outfit>.from(res.data['res'].map((data){
      Map<String, dynamic> formattedDoc = Map<String, dynamic>.from(data);
      return Outfit.fromMap(formattedDoc);
    }).toList());
  }
  List<Lookbook> _resToLookbookList(HttpsCallableResult res){
    return List<Lookbook>.from(res.data['res'].map((data){
      Map<String, dynamic> formattedDoc = Map<String, dynamic>.from(data);
      return Lookbook.fromMap(formattedDoc);
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
    .catchError((exception) => catchExceptionWithBool(exception, analytics));
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
    .catchError((exception) => catchExceptionWithBool(exception, analytics));
  }

  Future<bool> editOutfit(EditOutfit editOutfit) async {
    cache.editOutfit(editOutfit);
    return cloudFunctions.getHttpsCallable(functionName: 'editOutfit').call(editOutfit.toJson())
    .then((res) async {
      bool status = res.data['res'];
      return status;
    })
    .catchError((exception) => catchExceptionWithBool(exception, analytics));
  }

  Future<bool> editLookbook(EditLookbook editLookbook) async {
  cache.editLookbook(editLookbook);
    return cloudFunctions.getHttpsCallable(functionName: 'editLookbook').call(editLookbook.toJson())
    .then((res) async {
      bool status = res.data['res'];
      return status;
    })
    .catchError((exception) => catchExceptionWithBool(exception, analytics));
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
    .catchError((exception) => catchExceptionWithBool(exception, analytics));
  }

  Future<int> saveOutfit(OutfitSave saveData) async {
    return cloudFunctions.getHttpsCallable(functionName: 'saveOutfit').call(saveData.toJson())
    .then((res) async {
      int saveId = res.data['ref'];
      bool isNewSave = saveId > 0;
      if(isNewSave){
        await cache.addSave(saveData, saveId);
      }
      return saveId;
    })
    .catchError((exception) => catchExceptionWithInt(exception, analytics));
  }

  Future<bool> deleteSave(DeleteSave deleteSave){
    cache.deleteSave(deleteSave);
    return cloudFunctions.getHttpsCallable(functionName: 'deleteSave').call(deleteSave.toJson())
    .then((res) => true)
    .catchError((exception) => catchExceptionWithBool(exception, analytics));
  }
  Future<bool> deleteLookbook(Lookbook lookbook){
    cache.deleteLookbook(lookbook);
    return cloudFunctions.getHttpsCallable(functionName: 'deleteLookbook').call(lookbook.toJson())
    .then((res) => true)
    .catchError((exception) => catchExceptionWithBool(exception, analytics));
  }

  Future<void> clearLookbooks() => cache.clearLookbooks();

  Future<bool> rateOutfit(OutfitRating outfitRating) async {
    cache.rateOutfit(outfitRating);
    return cloudFunctions.getHttpsCallable(functionName: 'rateOutfit').call(outfitRating.toJson())
    .then((res) async {
      bool status = res.data['res'];
      return status;
    })
    .catchError((exception) => catchExceptionWithBool(exception, analytics));
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
    .catchError((exception) => catchExceptionWithBool(exception, analytics));
  }

  Future<bool> createLookbook(AddLookbook addLookbook){
    return cloudFunctions.getHttpsCallable(functionName: 'addLookbook').call(addLookbook.toJson())
    .then((res) async {
      int lookbookId = res.data['res'];
      Lookbook lookbook = Lookbook(
        lookbookId: lookbookId,
        userId: addLookbook.userId,
        name: addLookbook.name,
        description: addLookbook.description,
        createdAt: DateTime.now(),
      );
      await cache.addLookbook(lookbook);
      return true;
    })
    .catchError((exception) => catchExceptionWithBool(exception, analytics));
  }



  Future<bool> likeComment(CommentLike commentlike) async {
    cache.likeComment(commentlike);
    return cloudFunctions.getHttpsCallable(functionName: 'likeComment').call(commentlike.toJson())
    .then((res) async {
      bool status = res.data['res'];
      return status;
    })
    .catchError((exception) => catchExceptionWithBool(exception, analytics));
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
    .catchError((exception) => catchExceptionWithBool(exception, analytics));
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
    .catchError((exception) => catchExceptionWithBool(exception, analytics));
  }


}