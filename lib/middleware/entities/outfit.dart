import '../../../middleware/entities.dart';

class Outfit {

  int outfitId;
  List<String> images;
  String title;
  String description;
  String style;
  double _averageRating;
  double hiddenRating;
  int ratingsCount;
  int commentsCount;
  User poster;
  DateTime createdAt;
  int userRating;
  SearchOutfit searchOutfit;
  Save save;

  Outfit({
    this.outfitId,
    this.images, 
    this.title, 
    this.description, 
    this.style,
    this.hiddenRating,
    this.ratingsCount,
    this.commentsCount,
    this.poster,
    this.createdAt,
  });

  set averageRating(double newRating) => _averageRating = newRating;
  double get averageRating {
    int roundedRating = (_averageRating*10).round();
    return roundedRating/10;
  }
  double get trueAverageRating => averageRating;

  bool get hasCompleteData => commentsCount != null;

  bool get hasAdditionalInfo => hasMultipleImages || hasDescription;  
  bool get hasMultipleImages => images.length > 1;
  bool get hasDescription => description != null && description.length > 0;

  bool get hasRating => userRating != null;

  Outfit.fromMap(Map<String, dynamic> map){
    outfitId = map['outfit_id'];
    createdAt = DateTime.parse(map['outfit_created_at']);
    title = map['title'];
    description = map['description'];
    List<String> _images = [];
    for(int i = 0; i < 3; i++){
      final _image = map['image_url_${i+1}'];
      if(_image != null){
        _images.add(_image);
      }
    }
    images = _images;
    style = map['style'];
    _averageRating = map['average_rating'] == null ? 0 : double.parse(map['average_rating'].toString());
    ratingsCount = map['ratings_count'];
    commentsCount = map['comments_count'];
    userRating = map['user_rating'];
    hiddenRating =  map['hidden_rating']?.toDouble();
    poster = User.fromMap(map);
    searchOutfit = SearchOutfit.fromMap(map);
    save = Save.fromMap(map);
  } 

  Map<String, dynamic> toJson() => {
    'outfit_id' : outfitId, 
    'poster_user_id': poster.userId,
    'image_url_1' : images[0],
    'image_url_2' : images.length > 1 ? images[1] : null,
    'image_url_3' : images.length > 2 ? images[2] : null, 
    'title' : title, 
    'description' : description, 
    'style' : style,
    'average_rating': _averageRating,
    'ratings_count' :ratingsCount,
    'user_rating' : userRating,
    'hidden_rating': hiddenRating,
    'outfit_created_at' : createdAt.toIso8601String(), 
    'comments_count':commentsCount,
  };

}