import 'package:middleware/entities.dart';

class LoadComments {

  String userId;
  int outfitId;
  Comment startAfterComment;
  
  LoadComments({
    this.userId,
    this.outfitId,
    this.startAfterComment,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'outfit_id': outfitId,
    'start_after_comment': startAfterComment?.toJson(),
  };


  
  bool operator ==(o) {
    return o is LoadComments &&
    o.userId == userId &&
    o.outfitId == outfitId &&
    o.startAfterComment?.commentId == startAfterComment?.commentId;
  }
}