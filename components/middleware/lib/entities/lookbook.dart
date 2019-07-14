class Lookbook {
  int lookbookId;
  String userId;
  String name, description;
  int numberOfOutfits;
  DateTime createdAt;

  Lookbook({
    this.lookbookId,
    this.userId,
    this.name,
    this.description,
    this.createdAt,
  });

  Lookbook.fromMap(Map<String, dynamic> map){
    lookbookId = map['lookbook_id'];
    userId = map['lookbook_user_id'];
    name= map['lookbook_name'];
    description = map['lookbook_description'];
    if(description==''){
      description=null;
    }
    numberOfOutfits = map['number_of_outfits'] == null ? 0 : map['number_of_outfits'];
    createdAt = DateTime.parse(map['lookbook_created_at']);
  } 

  Map<String, dynamic> toJson() => {
    'lookbook_id' : lookbookId, 
    'lookbook_user_id': userId,
    'lookbook_name' : name,
    'lookbook_description' : description ,
    'number_of_outfits' : numberOfOutfits==null ? 0 :numberOfOutfits,
    'lookbook_created_at' : createdAt?.toIso8601String(),
  };

}