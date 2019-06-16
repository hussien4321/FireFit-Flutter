class Save {
  int saveId;
  int outfitId;
  String userId;
  DateTime createdAt;

  Save({
    this.saveId,
    this.outfitId,
    this.userId,
    this.createdAt,
  });

  Save.fromMap(Map<String, dynamic> map){
    if(map['save_id'] != null){
      saveId = map['save_id'];
      outfitId = map['save_outfit_id'];
      userId = map['save_user_id'];
      createdAt = DateTime.parse(map['save_created_at']);
    }
  } 

  Map<String, dynamic> toJson() => {
    'save_id' : saveId, 
    'save_outfit_id' : outfitId,
    'save_user_id' : userId,
    'save_created_at' : createdAt.toIso8601String(),
  };

}