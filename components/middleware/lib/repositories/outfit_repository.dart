import 'dart:async';
import 'package:middleware/middleware.dart';

abstract class OutfitRepository{

  Stream<List<Outfit>> getOutfits(SearchModes searchMode);
  Stream<Outfit> getOutfit(SearchModes searchMode);
  Future<bool> loadOutfits(LoadOutfits loadOutfits);
  Future<bool> loadMoreOutfits(LoadOutfits loadOutfits);
  Future<bool> loadOutfit(LoadOutfit loadOutfit);
  Future<bool> uploadOutfit(UploadOutfit uploadOutfit); 
  Future<bool> editOutfit(EditOutfit editOutfit); 
  Future<bool> saveOutfit(OutfitSave saveData);
  Future<bool> rateOutfit(OutfitRating outfitRating);
  Future<bool> deleteOutfit(Outfit outfitToDelete);


  Stream<List<Comment>> getComments();
  Future<bool> loadComments(LoadComments loadComments);
  Future<bool> loadMoreComments(LoadComments loadComments);
  Future<bool> addComment(AddComment comment);
  Future<bool> likeComment(CommentLike commentlike);
  Future<bool> deleteComment(DeleteComment deleteComment);
}