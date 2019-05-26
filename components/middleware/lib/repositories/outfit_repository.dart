import 'dart:async';
import 'package:middleware/middleware.dart';

abstract class OutfitRepository {

  Stream<List<Outfit>> getOutfits();

  Future<bool> exploreOutfits();

  Future<bool> uploadOutfit(UploadOutfit uploadOutfit); 

  Future<bool> deleteOutfit(Outfit outfitToDelete);

}