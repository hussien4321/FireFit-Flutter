import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:middleware/middleware.dart';
import 'package:helpers/helpers.dart';
import 'package:front_end/providers.dart';
import 'package:blocs/blocs.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommentsScreen extends StatefulWidget {

  final int outfitId;
  final bool loadOutfit;
  final bool focusComment;
  
  CommentsScreen({
    this.outfitId,
    this.loadOutfit = false,
    this.focusComment = false,
  });

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  
  OutfitBloc _outfitBloc;
  CommentBloc _commentBloc;

  String userId;

  bool canSendComment = false;
  TextEditingController commentTextController = new TextEditingController();


  Comment lastComment;

  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }
  _scrollListener() {
    if (_controller.offset >= (_controller.position.maxScrollExtent - 100) && !_controller.position.outOfRange) {
      _commentBloc.loadComments.add(LoadComments(
        userId: userId,
        outfitId: widget.outfitId,
        startAfterComment: lastComment,
      ));
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return CustomScaffold(
      title: "Comments",
      body: Container(
        child: StreamBuilder<bool>(
          stream: _outfitBloc.isLoading,
          initialData: true,
          builder: (context, loadingSnap) => StreamBuilder<Outfit>(
            stream: _outfitBloc.selectedOutfit,
            builder: (context, outfitSnap) {
              if(loadingSnap.data || !outfitSnap.hasData || outfitSnap.data == null){
                return _loadingPlaceholder();
              }
              Outfit outfit = outfitSnap.data;
              return Column(
                children: [
                  _commentInput(outfit),
                  _buildOutfitText(outfit),
                  _buildCommentsCount(outfit),
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    width: double.infinity,
                    height: 0.5,
                    color: Colors.grey.withOpacity(0.5)
                  ),
                  StreamBuilder<List<Comment>>(
                    stream: _commentBloc.comments,
                    initialData: [],
                    builder: (ctx, snap) {
                      if(snap.data.length>0){
                        lastComment = snap.data.last;
                      } 
                      return Expanded(
                        child: PullToRefreshOverlay(
                          matchSize: false,
                          onRefresh: () async {
                            _commentBloc.loadComments.add(LoadComments(
                              userId: userId,
                              outfitId: widget.outfitId,
                            ));
                          },
                          child: ListView(
                            padding: EdgeInsets.all(0),
                            controller: _controller,
                            children: snap.data.map((comment) => _buildCommentField(comment)).toList()..add(
                              StreamBuilder<bool>(
                                stream: _commentBloc.isLoading,
                                initialData: false,
                                builder: (ctx, loadingSnap) => loadingSnap.data ? _loadingPlaceholder() : Container(),
                              )
                            )
                          ),
                        ),
                      );
                    },
                  )
                ]
              );
            }
          ),
        ),
      ),
    );
  }

  _loadingPlaceholder() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator()
      )
    );
  }
  
  _initBlocs() async {
    if(_commentBloc==null){
      _commentBloc = CommentBlocProvider.of(context);
      _outfitBloc = OutfitBlocProvider.of(context);
      userId = await UserBlocProvider.of(context).existingAuthId.first;
      _commentBloc.loadComments.add(LoadComments(
        userId: userId,
        outfitId: widget.outfitId,
      ));
      _outfitBloc.selectOutfit.add(LoadOutfit(
        outfitId: widget.outfitId,
        userId: userId,
        loadFromCloud: widget.loadOutfit
      ));
    }
  }
  
  Widget _commentInput(Outfit outfit){
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
                    onSubmitted: (s) => _sendComment(outfit),
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
                onPressed: () => _sendComment(outfit),
              ) : Container(),
            ],
          ),
        ),
      ),
    );
  }

  _sendComment(Outfit outfit) {
    AddComment addComment = new AddComment(
      commentText: commentTextController.text,
      outfit: outfit,
      userId: userId,
    );
    setState(() {
     canSendComment = false; 
    });
    _commentBloc.addComment.add(addComment);
    commentTextController.clear();
  }

  Widget _buildOutfitText(Outfit outfit) {
    return InkWell(
      highlightColor: Colors.blueGrey,
      onTap: _openOutfit,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ProfilePicWithShadow(
                heroTag: '${outfit.outfitId}-'+outfit.poster.profilePicUrl,
                userId: outfit.poster.userId,
                url: outfit.poster.profilePicUrl,
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
                      outfit.poster.name,
                      style: Theme.of(context).textTheme.subtitle
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: Text(
                      outfit.title
                    ),
                  ),
                  outfit.description == null ? Container() : Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
                    child: Text(
                      outfit.description,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 8.0),
              width: 35.0,
              height: 60.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(outfit.images.first),
                  fit: BoxFit.cover
                ),
                border: Border.all(
                  width: 0.5
                ),
                color: Colors.grey
              ),
            )
          ],
        ),
      ),
    );
  }

  _openOutfit() {
    CustomNavigator.goToOutfitDetailsScreen(context, true, 
      outfitId: widget.outfitId
    );
  }
  
  Widget _buildCommentsCount(Outfit outfit) {
    return Text(
      "${outfit.commentsCount} Comment${outfit.commentsCount==1?'':'s'}",
      style: Theme.of(context).textTheme.caption,
    );
  }

  Widget _buildCommentField(Comment comment) {
    bool isCurrentUser = userId == comment.commenter.userId;
    return InkWell(
      highlightColor:  Colors.blueGrey,
      onLongPress: isCurrentUser ?  ()=>_confirmDelete(comment) : null,
      child: Container(
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          comment.isLiked ? FontAwesomeIcons.solidHeart :  FontAwesomeIcons.heart,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _likeComment(comment),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.only(left: 48),
              width: double.infinity,
              child: Row(
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
      ),
    );
  }


  _confirmDelete(Comment comment){
    DeleteComment deleteComment = DeleteComment(
      comment: comment,
      outfitId: widget.outfitId,
    );
    return showDialog(
      context: context,
      builder: (secondContext) {
        return YesNoDialog(
          title: 'Delete Comment',
          description: 'Are you sure you want to delete this comment?',
          yesText: 'Yes',
          noText: 'Cancel',
          onYes: () {
            _commentBloc.deleteComment.add(deleteComment);
          },
          onDone: () {
            Navigator.pop(context);
          },
        );
      }
    ) ?? false;
  }

  _likeComment(Comment comment) {
    CommentLike commentLike =CommentLike(
      comment: comment,
      outfitId: widget.outfitId,
      userId: userId
    );
    _commentBloc.likeComment.add(commentLike);
  }
}