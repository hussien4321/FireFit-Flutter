import '../../../middleware/middleware.dart';

class OutfitSave {

  String userId;
  int lookbookId;
  Outfit outfit;

  OutfitSave({
    this.userId,
    this.outfit,
    this.lookbookId,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'lookbook_id' : lookbookId,
    'outfit_id' : outfit.outfitId,
  };
}