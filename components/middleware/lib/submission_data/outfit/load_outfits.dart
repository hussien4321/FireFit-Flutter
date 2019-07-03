import 'package:middleware/entities.dart';

enum SearchModes {
  EXPLORE, MINE, SAVED, SELECTED, SELECTED_SINGLE, FEED, NOTIFICATIONS, FOLLOWERS, FOLLOWING, TEMP
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
    case SearchModes.SELECTED_SINGLE:
      return 'selected-single';
    case SearchModes.NOTIFICATIONS:
      return 'notifications';
    case SearchModes.FOLLOWERS:
      return 'followers';
    case SearchModes.FOLLOWING:
      return 'following';
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
  String category;
  bool sortByTop;
  bool forceLoad;
  
  LoadOutfits({
    this.userId,
    this.startAfterOutfit,
    this.category,
    this.sortByTop = false,
    this.forceLoad = false,
  });

  bool operator ==(o) {
    return o is LoadOutfits &&
    o.userId == userId &&
    o.startAfterOutfit == startAfterOutfit &&
    !o.forceLoad &&
    o.category == category&&
    o.sortByTop == sortByTop;
  }

  Map<String, dynamic> toJson() => {
    'search_mode': searchModeToString(searchMode),
    'user_id': userId,
    'start_after_outfit': startAfterOutfit?.toJson(),
    'start_after_save':startAfterOutfit?.save?.toJson(),
    'category': category,
    'sort_by_top': sortByTop,
  };

}