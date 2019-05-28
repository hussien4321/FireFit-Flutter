import 'dart:async';
import 'package:middleware/middleware.dart';

abstract class OutfitRepository {

  Stream<List<Outfit>> getOutfits();
  
  Stream<Outfit> getOutfit(int outfitId);

  Future<bool> exploreOutfits(ExploreOutfits explore);

  Future<bool> uploadOutfit(UploadOutfit uploadOutfit); 

  Future<bool> deleteOutfit(Outfit outfitToDelete);

  Future<bool> impressOutfit(OutfitImpression outfitImpression);

}