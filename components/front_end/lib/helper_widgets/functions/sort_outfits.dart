import 'package:middleware/middleware.dart';



List<Outfit> sortOutfits(List<Outfit> outfits, bool isSortingByTop){
  if(isSortingByTop){
    outfits.sort((a, b) {
      int firstValue = (a.hiddenRating == null || b.hiddenRating == null) ? 1 : -a.hiddenRating.compareTo(b.hiddenRating);
      if(firstValue==0){
        return a.outfitId.compareTo(b.outfitId);
      }
      return firstValue;
    });
  }else{
    outfits.sort((a, b) => -a.createdAt.compareTo(b.createdAt));
  }
  return outfits;
}


List<Outfit> sortLookbookOutfits(List<Outfit> outfits, bool isSortingByTop){
  if(isSortingByTop){
    outfits.sort((a, b) {
      int firstValue = (a.hiddenRating == null || b.hiddenRating == null) ? 1 : -a.hiddenRating.compareTo(b.hiddenRating);
      if(firstValue==0){
        return a.outfitId.compareTo(b.outfitId);
      }
      return firstValue;
    });
  }else{
    outfits.sort((a, b) => -a.save.createdAt?.compareTo(b.save.createdAt));
  }
  return outfits;
}
