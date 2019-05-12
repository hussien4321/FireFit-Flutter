import 'package:middleware/entities.dart';

class Comment {

  User commenter;
  DateTime uploadDate;
  String text;
  int likesCount;

  Comment({
    this.commenter,
    this.uploadDate,
    this.text,
    this.likesCount,
  });
  
}