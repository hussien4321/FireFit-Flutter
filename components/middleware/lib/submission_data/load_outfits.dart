enum SearchModes {
  EXPLORE, MINE, SAVED, SELECTED, FEED, NOTIFICATIONS, FOLLOW, TEMP
}

String searchModeToString(SearchModes searchMode){
  switch (searchMode) {
    case SearchModes.EXPLORE:
      return 'explore';
    case SearchModes.FEED:
      return 'feed';
    case SearchModes.MINE:
      return 'mine';
    case SearchModes.SAVED:
      return 'saved';
    case SearchModes.SELECTED:
      return 'selected';
    case SearchModes.NOTIFICATIONS:
      return 'notifications';
    case SearchModes.FOLLOW:
      return 'follow';
    case SearchModes.TEMP:
      return 'temp';
    default:
      return null;
  }
}

class LoadOutfits {

  SearchModes searchMode;
  String userId;
  String startAfterUserId;
  String category;
  bool sortByTop;
  
  LoadOutfits({
    this.userId,
    this.startAfterUserId,
    this.category,
    this.sortByTop = false,
  });

  bool operator ==(o) {
    return o is LoadOutfits &&
    o.userId == userId &&
    o.startAfterUserId == startAfterUserId &&
    o.category == category&&
    o.sortByTop == sortByTop;
  }

  Map<String, dynamic> toJson() => {
    'search_mode': searchModeToString(searchMode),
    'user_id': userId,
    'start_after_user_id': startAfterUserId,
    'category': category,
    'sort_by_top': sortByTop,
  };

}