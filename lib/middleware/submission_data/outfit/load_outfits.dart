import '../../../middleware/middleware.dart';

enum SearchModes {
  EXPLORE, MINE, SAVED, SELECTED, SELECTED_SINGLE, FEED, NOTIFICATIONS, FOLLOWERS, FOLLOWING, TEMP, BLOCKED
}

List<SearchModes> searchModesToNOTClearEachTime = [
  SearchModes.MINE,
  SearchModes.NOTIFICATIONS,
];
List<SearchModes> searchModesToClearOnStart = [
  SearchModes.EXPLORE,
  SearchModes.FEED,
];

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
    case SearchModes.SELECTED_SINGLE:
      return 'selected-single';
    case SearchModes.NOTIFICATIONS:
      return 'notifications';
    case SearchModes.FOLLOWERS:
      return 'followers';
    case SearchModes.FOLLOWING:
      return 'following';
    case SearchModes.BLOCKED:
      return 'blocked';
    case SearchModes.TEMP:
      return 'temp';
    default:
      return null;
  }
}

class LoadOutfits {

  SearchModes searchMode;
  String userId;
  Outfit startAfterOutfit;
  bool sortByTop;
  bool forceLoad;
  int lookbookId;
  OutfitFilters filters;

  
  LoadOutfits({
    this.userId,
    this.startAfterOutfit,
    this.searchMode,
    this.filters,
    this.lookbookId,
    this.sortByTop = false,
    this.forceLoad = false,
  }) {
    if(filters==null){
      filters=OutfitFilters();
    }
  }

  bool operator ==(newData) {
    return newData is LoadOutfits &&
    newData.userId == userId &&
    (newData.startAfterOutfit == startAfterOutfit && newData.startAfterOutfit!=null && startAfterOutfit!=null) &&
    !newData.forceLoad &&
    newData.lookbookId == lookbookId&&
    newData.filters == filters &&
    newData.sortByTop == sortByTop;
  }

  Map<String, dynamic> toJson() => {
    'search_mode': searchModeToString(searchMode),
    'user_id': userId,
    'lookbook_id': lookbookId,
    'start_after_outfit': startAfterOutfit?.toJson(),
    'start_after_save':startAfterOutfit?.save?.toJson(),
    'filters': filters == null || filters.isEmpty ? null : filters.toJson(),
    'sort_by_top': sortByTop,
  };

}