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
  List<Comment> comments;
  DateTime created_at;

  Outfit({
    this.outfit_id,
    this.images, 
    this.title, 
    this.description, 
    this.style,
    this.likesCount,
    this.commentsCount,
    this.poster,
    this.comments,
  });

  Outfit.fromMap(Map<String, dynamic> map){
    outfit_id = map['outfit_id'];
    created_at = DateTime.parse(map['created_at']);
    title = map['title'];
    description = map['description'];
    List<String> _images = [];
    for(int i = 0; i < 3; i++){
      final _image = map['image_url_$i'];
      if(_image != null){
        _images.add(_image);
      }
    }
    images = _images;
    style = map['style'];
  } 

  Map<String, dynamic> toJson() => {
    'outfit_id' : outfit_id, 
    'image_url_1' : images[0],
    'image_url_2' : images.length > 1 ? images[1] : null,
    'image_url_3' : images.length > 2 ? images[2] : null, 
    'title' : title, 
    'description' : description, 
    'style' : style, 
    'created_at' : created_at, 
  };
}