import 'dart:async';
import 'package:middleware/middleware.dart';

abstract class OutfitRepository{

  Stream<List<Outfit>> getOutfits();
  
  Stream<Outfit> getOutfit(int outfitId);

  Stream<List<Comment>> getComments();

  Future<bool> exploreOutfits(ExploreOutfits explore);

  Future<bool> loadComments(LoadComments loadComments);

  Future<bool> uploadOutfit(UploadOutfit uploadOutfit); 

  Future<bool> deleteOutfit(Outfit outfitToDelete);

  Future<bool> impressOutfit(OutfitImpression outfitImpression);

  Future<bool> addComment(AddComment comment);

  Future<bool> likeComment(CommentLike commentlike);

}