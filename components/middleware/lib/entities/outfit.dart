import 'package:middleware/entities.dart';

class Outfit {

  int outfit_id;
  List<String> images;
  String title;
  String description;
  String style;
  int likesCount;
  int commentsCount;
  User poster;
  DateTime createdAt;

  Outfit({
    this.outfit_id,
    this.images, 
    this.title, 
    this.description, 
    this.style,
    this.likesCount,
    this.commentsCount,
    this.poster,
    this.createdAt,
  });


  bool get hasMultipleImages => images.length > 1;

  Outfit.fromMap(Map<String, dynamic> map, {bool cache = false}){
    outfit_id = map['outfit_id'];
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
    commentsCount = map['comments_count'] == null ? 0 : map['comments_count'];
    if(!cache){
      poster = User.fromMap(map);
    }
  } 

  Map<String, dynamic> toJson({bool cache = false}) => {
    'outfit_id' : outfit_id, 
    'poster_user_id': poster.userId,
    'image_url_1' : images[0],
    'image_url_2' : images.length > 1 ? images[1] : null,
    'image_url_3' : images.length > 2 ? images[2] : null, 
    'title' : title, 
    'description' : description, 
    'style' : style, 
    'outfit_created_at' : cache ? createdAt.toIso8601String() : createdAt, 
    'likes_count':likesCount,
    'comments_count':commentsCount,
  };

}