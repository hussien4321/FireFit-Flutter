import '../../../middleware/middleware.dart';

class LoadLookbooks {

  String userId;
  Lookbook startAfterLookbook;
  bool sortBySize;

  LoadLookbooks({
    this.userId,
    this.startAfterLookbook,
    this.sortBySize = false,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'start_after_lookbook': startAfterLookbook?.toJson(),
    'sort_by_size': sortBySize,
  };
}