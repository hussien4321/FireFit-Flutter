import 'package:middleware/middleware.dart';

class AddLookbook {

  String userId;
  String name;
  String description;

  AddLookbook({
    this.userId,
    this.name,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'lookbook_user_id': userId,
    'lookbook_name': name,
    'lookbook_description' : description.isEmpty ? null : description,
  };
}