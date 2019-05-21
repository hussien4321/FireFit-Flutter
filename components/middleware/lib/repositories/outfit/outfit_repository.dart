import 'dart:async';
import 'package:middleware/middleware.dart';

abstract class OutfitRepository {

  Stream<List<Outfit>> getOutfits();

  Future<bool> exploreOutfits();

  Future<bool> uploadOutfit(CreateOutfit createOutfit); 

}