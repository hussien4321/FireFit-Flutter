class LoadComments {

  String userId;
  int outfitId;
  
  LoadComments({
    this.userId,
    this.outfitId
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'outfit_id': outfitId,
  };
}