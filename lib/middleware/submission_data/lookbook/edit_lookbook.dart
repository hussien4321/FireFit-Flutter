import '../../../middleware/entities.dart';

class EditLookbook {

  int lookbookId;
  String userId;
  String name;
  String description;

  EditLookbook({
    this.lookbookId,
    this.userId,
    this.name, 
    this.description,
  });

  EditLookbook.fromOutfit(Lookbook lookbookToUpdate) :
    lookbookId= lookbookToUpdate.lookbookId,
    userId =lookbookToUpdate.userId,
    name = lookbookToUpdate.name,
    description = lookbookToUpdate.description;

  bool get canBeUpdated => lookbookId!=null && userId!=null && hasName && hasDescription;

  bool get hasName => name != null  && name.isNotEmpty;
  bool get hasDescription => description != null  && description.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'lookbook_id': lookbookId,
    'lookbook_user_id': userId,
    'lookbook_name': name, 
    'lookbook_description': description,
  };
}