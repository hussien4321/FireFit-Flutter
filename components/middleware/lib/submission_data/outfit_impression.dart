import 'package:middleware/middleware.dart';

class OutfitImpression {

  String userId;
  Outfit outfit;
  int impressionValue;

  OutfitImpression({
    this.userId,
    this.outfit,
    this.impressionValue,
  });

  Map<String, dynamic> toJson() => {
    'impression_user_id': userId,
    'poster_user_id': outfit.poster.userId,
    'outfit_id' : outfit.outfit_id,
    'impression_value' :impressionValue,
  };
}