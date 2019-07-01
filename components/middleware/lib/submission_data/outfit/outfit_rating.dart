import 'package:middleware/middleware.dart';

class OutfitRating {

  String userId;
  Outfit outfit;
  int ratingValue;

  OutfitRating({
    this.userId,
    this.outfit,
    this.ratingValue,
  });

  Map<String, dynamic> toJson() => {
    'rating_user_id': userId,
    'poster_user_id': outfit.poster.userId,
    'outfit_id' : outfit.outfitId,
    'rating_value' :ratingValue,
  };
}