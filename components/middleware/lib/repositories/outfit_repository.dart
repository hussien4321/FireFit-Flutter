import 'dart:async';
import 'package:middleware/middleware.dart';

abstract class OutfitRepository{

  Stream<List<Outfit>> getOutfits();
  Stream<Outfit> getOutfit(int outfitId);
  Future<bool> loadOutfits(OutfitsSearch outfitsSearch);
  Future<bool> loadMoreOutfits(OutfitsSearch outfitsSearch);
  Future<bool> uploadOutfit(UploadOutfit uploadOutfit); 
  Future<bool> saveOutfit(OutfitSave saveData);
  Future<bool> impressOutfit(OutfitImpression outfitImpression);
  Future<bool> deleteOutfit(Outfit outfitToDelete);


  Stream<List<Comment>> getComments();
  Future<bool> loadComments(LoadComments loadComments);
  Future<bool> addComment(AddComment comment);
  Future<bool> likeComment(CommentLike commentlike);
}