import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:middleware/middleware.dart';
import 'package:helpers/helpers.dart';
import 'package:front_end/providers.dart';
import 'package:blocs/blocs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:rxdart/rxdart.dart';
import 'package:helpers/helpers.dart';


class CommentsScreen extends StatefulWidget {

  final Outfit outfit;
  final bool focusComment;
  
  CommentsScreen({
    this.outfit,
    this.focusComment = false,
  });

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  
  CommentBloc _commentBloc;

  String userId;

  bool canSendComment = false;
  TextEditingController commentTextController = new TextEditingController();


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        title: Text('Comments'),
        backgroundColor: Colors.white,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _commentInput(),
              _buildOutfitText(),
              Divider(color: Colors.grey.withOpacity(0.5)),
              StreamBuilder<List<Comment>>(
                stream: _commentBloc.comments,
                initialData: [],
                builder: (ctx, snap) {
                  return Column(
                    children: snap.data.map((comment) => _buildCommentField(comment)).toList()..add(
                      StreamBuilder<bool>(
                        stream: _commentBloc.isLoading,
                        initialData: true,
                        builder: (ctx, loadingSnap) => loadingSnap.data ? Center(child: CircularProgressIndicator(),) : Container(),
                      )
                    )
                  );
                },
              )
            ]
          ),
        ),
      ),
    );
  }
  
  _initBlocs() async {
    if(_commentBloc==null){
      _commentBloc = CommentBlocProvider.of(context);
      userId = await UserBlocProvider.of(context).existingAuthId.first;
      _commentBloc.loadComments.add(LoadComments(
        userId: userId,
        outfitId: widget.outfit.outfitId,
      ));
    }
  }
  
  Widget _commentInput(){
    return Container(
      child: Material(
        color: Colors.grey[300],
        child: InkWell(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0)
                  ),
                  child: TextField(
                    autofocus: widget.focusComment,
                    controller: commentTextController,
                    onChanged: (text) {
                      setState(() {
                        canSendComment = text.isNotEmpty;                      
                      });
                    },
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Add a comment...'
                    ),
                  ),
                ),
              ),
              canSendComment ? IconButton(
                icon: Icon(Icons.send),
                onPressed: _sendComment,
              ) : Container(),
            ],
          ),
        ),
      ),
    );
  }

  _sendComment() {
    AddComment addComment = new AddComment(
      commentText: commentTextController.text,
      outfit: widget.outfit,
      userId: userId,
    );
    setState(() {
     canSendComment = false; 
    });
    _commentBloc.addComment.add(addComment);
    commentTextController.clear();
  }

  Widget _buildOutfitText() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ProfilePicWithShadow(
              heroTag: '${widget.outfit.outfitId}-'+widget.outfit.poster.profilePicUrl,
              userId: widget.outfit.poster.userId,
              url: widget.outfit.poster.profilePicUrl,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 2.0),
                  child: Text(
                    widget.outfit.poster.name,
                    style: Theme.of(context).textTheme.subtitle
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    widget.outfit.title
                  ),
                ),
                widget.outfit.description == null ? Container() : Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
                  child: Text(
                    widget.outfit.description,
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCommentField(Comment comment) {
    return Container(
      padding: EdgeInsets.only(bottom: 4.0, left: 8.0, right: 8.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ProfilePicWithShadow(
                  heroTag: '${comment.commentId}-'+comment.commenter.profilePicUrl,
                  userId: comment.commenter.userId,
                  url: comment.commenter.profilePicUrl,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 8.0, bottom: 2.0),
                      child: Text(
                        comment.commenter.name,
                        style: Theme.of(context).textTheme.subtitle
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.grey[350]
                      ),
                      width: double.infinity,
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        comment.text,
                      ),
                    ),
                  ],
                ),
              ),
              comment.commentId <= 0 ? 
              Container(
                margin: EdgeInsets.only(top: 16, left: 8.0),
                child: Center(
                  child: CircularProgressIndicator()
                )
              ) : 
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: IconButton(
                  icon: Icon(
                    comment.isLiked ? FontAwesomeIcons.solidHeart :  FontAwesomeIcons.heart,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => _likeComment(comment),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(left: 48),
            width: double.infinity,
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  DateFormatter.dateToRecentFormat(comment.uploadDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic
                  )
                ),
                Padding(padding: EdgeInsets.only(right: 8.0),),
                Text(
                  '${comment.likesCount} like${comment.likesCount == 1 ? '': 's'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            )
          ),
        ],
      ),
    );
  }

  _likeComment(Comment comment) {
    CommentLike commentLike =CommentLike(
      comment: comment,
      outfitId: widget.outfit.outfitId,
      userId: userId
    );
    _commentBloc.likeComment.add(commentLike);
  }
}