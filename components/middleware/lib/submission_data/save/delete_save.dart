import 'package:middleware/middleware.dart';

class DeleteSave {

  String userId;
  Save save;

  DeleteSave({
    this.userId,
    this.save,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'save_id' : save.saveId,
  };
}