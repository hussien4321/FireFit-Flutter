import '../../../middleware/entities.dart';

class LoadComments {

  String userId;
  int outfitId;
  Comment startAfterComment;
  int replyTo;
  bool forceLoad;
  
  LoadComments({
    this.userId,
    this.outfitId,
    this.startAfterComment,
    this.replyTo,
    this.forceLoad = false,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'outfit_id': outfitId,
    'start_after_comment': startAfterComment?.toJson(),
    'comment_reply_to': replyTo,
  };


  
  bool operator ==(o) {
    return o is LoadComments &&
    o.userId == userId &&
    o.outfitId == outfitId &&
    o.replyTo == replyTo && 
    !o.forceLoad &&
    o.startAfterComment?.commentId == startAfterComment?.commentId;
  }
}