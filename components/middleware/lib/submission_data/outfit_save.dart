import 'package:middleware/middleware.dart';

class OutfitSave {

  String userId;
  Outfit outfit;

  OutfitSave({
    this.userId,
    this.outfit,
  });

  Map<String, dynamic> toJson() => {
    'save_user_id': userId,
    'outfit_id' : outfit.outfit_id,
    'is_saved' : outfit.isSaved,
  };
}