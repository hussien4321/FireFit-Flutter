class OutfitsSearch {

  String searchMode;
  String userId;
  String startAfterUserId;
  String category;
  bool sortByTop;
  
  
  OutfitsSearch({
    this.userId,
    this.startAfterUserId,
    this.category,
    this.sortByTop = false,
  });

  Map<String, dynamic> toJson() => {
    'search_mode':searchMode,
    'user_id': userId,
    'start_after_user_id': startAfterUserId,
    'category': category,
    'sort_by_top': sortByTop,
  };
}