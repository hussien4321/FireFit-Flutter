class UploadOutfit {

  String posterUserId;
  List<String> images;
  String title;
  String description;
  String style;

  UploadOutfit({
    this.posterUserId = '0123456789',
    this.images, 
    this.title, 
    this.description, 
    this.style,
  }) {
    if(images == null){
      images = [];
    }
    if(style == null){
      style = "casualwear";
    }
  }

  bool get canBeUploaded => imagesUploaded && titleUploaded && styleUploaded;

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