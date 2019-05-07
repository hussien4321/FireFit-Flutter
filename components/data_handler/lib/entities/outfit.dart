import 'package:data_handler/entities.dart';

class Outfit {
  
  int id;
  List<String> images;
  String name;
  String challenge;
  String style;
  int likesCount;
  int commentsCount;
  User poster;
  List<Comment> comments;

  Outfit({
    this.id,
    this.images, 
    this.name, 
    this.challenge, 
    this.style,
    this.likesCount,
    this.commentsCount,
    this.poster,
    this.comments,
  });
}