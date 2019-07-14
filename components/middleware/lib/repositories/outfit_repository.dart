import 'dart:async';
import 'package:middleware/middleware.dart';

abstract class OutfitRepository{
  Stream<List<Outfit>> getOutfits(SearchModes searchMode);
  Future<bool> loadOutfits(LoadOutfits loadOutfits);
  Future<bool> loadMoreOutfits(LoadOutfits loadOutfits);
  Future<void> clearOutfits(SearchModes searchMode);

  Stream<List<Lookbook>> getLookbooks();
  Future<bool> loadLookbooks(LoadLookbooks loadLookbooks);
  Future<bool> createLookbook(AddLookbook addLookbook);
  Future<bool> editLookbook(EditLookbook editLookbook);
  Future<bool> deleteLookbook(Lookbook deleteLookbook);
  Future<void> clearLookbooks();

  Stream<Outfit> getOutfit(SearchModes searchMode);
  Future<bool> loadOutfit(LoadOutfit loadOutfit);
  Future<bool> uploadOutfit(UploadOutfit uploadOutfit); 
  Future<bool> editOutfit(EditOutfit editOutfit); 
  Future<bool> deleteOutfit(Outfit outfitToDelete);
  Future<bool> rateOutfit(OutfitRating outfitRating);

  Future<int> saveOutfit(OutfitSave saveData);
  Future<bool> deleteSave(DeleteSave deleteSave);
  
  Stream<List<Comment>> getComments();
  Future<bool> loadComments(LoadComments loadComments);
  Future<bool> loadMoreComments(LoadComments loadComments);
  Future<bool> addComment(AddComment comment);
  Future<bool> likeComment(CommentLike commentlike);
  Future<bool> deleteComment(DeleteComment deleteComment);
}