class ExploreOutfits {

  String userId;
  
  ExploreOutfits({
    this.userId,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
  };
}