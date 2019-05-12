import 'dart:async';
import 'package:middleware/middleware.dart';

abstract class OutfitRepository {

  Future<List<Outfit>> getOutfits();

  // Future<bool> uploadClothes(ClothingItemEntity newClothingItem); 

  // Future<List<ClothingItemEntity>> searchClothes(ClothesQueryData clothesQuery); 

}