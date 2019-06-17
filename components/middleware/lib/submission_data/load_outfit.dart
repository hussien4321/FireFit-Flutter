class LoadOutfit {

  String userId;
  int outfitId;
  
  LoadOutfit({
    this.userId,
    this.outfitId,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'outfit_id': outfitId,
  };

}