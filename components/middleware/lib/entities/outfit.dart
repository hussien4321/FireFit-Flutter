import 'package:middleware/entities.dart';

class Outfit {

  int outfitId;
  List<String> images;
  String title;
  String description;
  String style;
  int likesCount;
  int dislikesCount;
  int commentsCount;
  User poster;
  DateTime createdAt;
  int userImpression;
  bool isSaved;

  Outfit({
    this.outfitId,
    this.images, 
    this.title, 
    this.description, 
    this.style,
    this.likesCount,
    this.commentsCount,
    this.poster,
    this.createdAt,
    this.isSaved
  });

  int get likesOverallCount => likesCount - dislikesCount;

  bool get hasAdditionalInfo => hasMultipleImages || hasDescription;
  
  bool get hasMultipleImages => images.length > 1;
  bool get hasDescription => description != null && description.length > 0;

  Outfit.fromMap(Map<String, dynamic> map, {bool cache = false}){
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
    likesCount = map['likes_count'] == null ? 0 : map['likes_count'];
    dislikesCount = map['dislikes_count'] == null ? 0 : map['dislikes_count'];
    commentsCount = map['comments_count'] == null ? 0 : map['comments_count'];
    userImpression = map['user_impression'] == null ? 0 : map['user_impression'];
    isSaved = map['is_saved'] == 1;
    if(!cache){
      poster = User.fromMap(map);
    }
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
    'user_impression' : userImpression,
    'outfit_created_at' : createdAt.toIso8601String(), 
    'likes_count':likesCount,
    'dislikes_count':dislikesCount,
    'comments_count':commentsCount,
    'is_saved': isSaved ? 1 : 0, 
  };

}