class UploadOutfit {

  String posterUserId;
  List<String> images;
  String title;
  String description;
  String style;
  DateTime lastUploadDate;
  bool isOnWardrobePage;

  UploadOutfit({
    this.posterUserId,
    this.images, 
    this.title, 
    this.description, 
    this.style,
    this.lastUploadDate,
    this.isOnWardrobePage = false,
  }) {
    if(images == null){
      images = [];
    }
    if(style == null){
      style = "casualwear";
    }
  }

  bool get canBeUploaded => posterUserId!=null && imagesUploaded && titleUploaded && styleUploaded;

  bool get imagesUploaded => images.length > 0;
  bool get styleUploaded => style != null;
  bool get titleUploaded => title != null  && title.isNotEmpty;
  bool get descriptionUploaded => description != null && description.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'poster_user_id': posterUserId,
    'title' : title, 
    'description' : description, 
    'style' : style, 
    'images_count': images.length
  };
}