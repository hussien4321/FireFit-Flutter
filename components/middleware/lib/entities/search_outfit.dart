class SearchOutfit {

  int outfitId;
  String searchMode;

  SearchOutfit({
    this.outfitId,
    this.searchMode,
  });

  SearchOutfit.fromMap(Map<String, dynamic> map){
    outfitId = map['search_user_id'];
    searchMode = map['search_user_mode'];
  } 

  Map<String, dynamic> toJson() => {
    'search_outfit_id' : outfitId, 
    'search_outfit_mode' : searchMode,
  };

}