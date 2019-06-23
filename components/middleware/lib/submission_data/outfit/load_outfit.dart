import 'load_outfits.dart';

class LoadOutfit {

  String userId;
  int outfitId;
  bool loadFromCloud;
  SearchModes searchModes;

  LoadOutfit({
    this.userId,
    this.outfitId,
    this.loadFromCloud = false,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'outfit_id': outfitId,
  };

}