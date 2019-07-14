import 'package:middleware/middleware.dart';

class DeleteLookbook {

  int userId;
  Lookbook lookbook;

  DeleteLookbook({
    this.userId,
    this.lookbook,
  });
  
  Map<String, dynamic> toJson() => {
    'lookbook_id': lookbook.lookbookId,
    'lookbook_user_id': userId,
  };
}