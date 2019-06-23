import 'package:middleware/entities.dart';

class EditOutfit {

  int outfitId;
  String userId;
  String title;
  String description;
  String style;

  EditOutfit({
    this.outfitId,
    this.userId,
    this.title, 
    this.description,
    this.style,
  });

  EditOutfit.fromOutfit(Outfit outfitToUpdate) :
    outfitId = outfitToUpdate.outfitId,
    userId = outfitToUpdate.poster.userId,
    title = outfitToUpdate.title,
    description = outfitToUpdate.description,
    style = outfitToUpdate.style;

  bool get canBeUpdated => outfitId!=null && hasTitle && hasStyle;

  bool get hasTitle => title != null  && title.isNotEmpty;
  bool get hasStyle => style != null  && style.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'outfit_id': outfitId,
    'poster_user_id': userId,
    'title' : title, 
    'description' : description, 
    'style' : style
  };
}