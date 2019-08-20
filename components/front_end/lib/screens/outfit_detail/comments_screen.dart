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
  final int pagesSinceOutfitScreen;
  final int pagesSinceProfileScreen;
  final bool isComingFromExploreScreen;
  
  CommentsScreen({
    this.outfitId,
    this.loadOutfit = false,
    this.focusComment = false,
    this.pagesSinceOutfitScreen = 0,
    this.pagesSinceProfileScreen = 0,
    this.isComingFromExploreScreen = false,
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
  FocusNode commentFocus =FocusNode();

  Comment replyingToComment;

  Comment lastComment;

  ScrollController _controller;
  List<Comment> comments = [];

  int showingRepliesForId;

  bool isOpeningPage = true;

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
          stream: _outfitBloc.isLoadingItems,
          initialData: false,
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
                  StreamBuilder<bool>(
                    stream: _commentBloc.isLoading,
                    initialData: false,
                    builder: (ctx, loadingCommentSnap) =>StreamBuilder<bool>(
                      stream: _commentBloc.isLoadingReply,
                      initialData: false,
                      builder: (ctx, loadingReplySnap) =>StreamBuilder<List<Comment>>(
                        stream: _commentBloc.comments,
                        initialData: [],
                        builder: (ctx, snap) {
                          if(snap.data.length>0){
                            lastComment = snap.data.last;
                            if(!loadingCommentSnap.data && !loadingReplySnap.data){
                              comments = snap.data;
                            }
                          }
                          if(snap.data.isEmpty){
                            comments = [];
                          }
                          return Expanded(
                            child: PullToRefreshOverlay(
                              matchSize: false,
                              onRefresh: () async {
                                _commentBloc.loadComments.add(LoadComments(
                                  userId: userId,
                                  outfitId: widget.outfitId,
                                  forceLoad: true,
                                ));
                                showingRepliesForId = null;
                              },
                              child: ListView(
                                physics: ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                padding: EdgeInsets.all(0),
                                controller: _controller,
                                children: [_outfitOverview(outfit)]..addAll(comments.map((comment) => _buildCommentField(comment, loadingReplySnap.data, comments)).toList()..add(
                                  loadingCommentSnap.data||isOpeningPage ? _loadingPlaceholder() : 
                                  comments.isEmpty ? _emptyNotice() : Container()
                                ))
                              )
                            )
                          );
                        }
                      )
                    )
                  )
                ]
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _emptyNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 32, right:32, top: 16),
      child: Text(
        'Be the first to leave some feedback for this fit!',
        style: Theme.of(context).textTheme.subhead,
        textAlign: TextAlign.center,
      )
    );
  }

  Widget _outfitOverview(Outfit outfit) {
    return Column(
      children: <Widget>[
        _buildOutfitText(outfit),
        _buildCommentsCount(outfit),
        Container(
          margin: EdgeInsets.only(top: 4),
          width: double.infinity,
          height: 0.5,
          color: Colors.grey.withOpacity(0.5)
        ),
      ],
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
      _outfitBloc.selectOutfit.add(LoadOutfit(
        outfitId: widget.outfitId,
        userId: userId,
        loadFromCloud: widget.loadOutfit
      ));
      _commentBloc.loadComments.add(LoadComments(
        userId: userId,
        outfitId: widget.outfitId,
      ));
      Future.delayed(Duration(milliseconds: 100), () {
        if(mounted){
          setState(() => isOpeningPage = false);
        }
      });
    }
  }
  
  Widget _commentInput(Outfit outfit){
    return Container(
      child: Material(
        color: Colors.grey[300],
        child: InkWell(
          child: Column(
            children: <Widget>[
              replyingToComment!=null ? _replyingToComment() : Container(),
              _commentTextField(outfit)
            ],
          ),
        ),
      ),
    );
  }

  Widget _replyingToComment() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Replying to: ',
                        style: Theme.of(context).textTheme.button.apply(
                          color: Colors.blue,
                        ),
                      ),
                      TextSpan(
                        text: replyingToComment.commenter.name,
                        style: Theme.of(context).textTheme.caption.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      TextSpan(
                        text: "'s Comment",
                        style: Theme.of(context).textTheme.caption.copyWith(
                          color: Colors.black,
                        ),
                      ),
                    ]
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    replyingToComment.text,
                    style: Theme.of(context).textTheme.body2.apply(
                      color: Colors.grey[700]
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white
            ),
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => _cancelReply(),
            ),
          ),
        ],
      ),
    );
  }

  _cancelReply() {
    setState(() {
      replyingToComment = null;    
    });
  }

  Widget _commentTextField(Outfit outfit) {
    return Row(
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
              focusNode: commentFocus,
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
    );
  }
  _sendComment(Outfit outfit) {
    AddComment addComment = new AddComment(
      commentText: commentTextController.text,
      outfit: outfit,
      userId: userId,
      replyingToComment: replyingToComment,
    );
    setState(() {
     canSendComment = false; 
    });
    commentFocus.unfocus();
    _commentBloc.addComment.add(addComment);
    commentTextController.clear();
    setState(() {
     replyingToComment = null; 
    });
  }

  Widget _buildOutfitText(Outfit outfit) {
    return InkWell(
      highlightColor: Colors.grey[700],
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
                pagesSinceOutfitScreen: widget.pagesSinceOutfitScreen,
                pagesSinceProfileScreen: widget.pagesSinceProfileScreen,
                isComingFromExploreScreen: widget.isComingFromExploreScreen,
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
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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
    CustomNavigator.goToOutfitDetailsScreen(context, 
      outfitId: widget.outfitId,
      pagesSinceOutfitScreen: widget.pagesSinceOutfitScreen,
      pagesSinceProfileScreen: widget.pagesSinceProfileScreen,
      isComingFromExploreScreen: widget.isComingFromExploreScreen,
    );
  }
  
  Widget _buildCommentsCount(Outfit outfit) {
    return Text(
      "${outfit.commentsCount} Comment${outfit.commentsCount==1?'':'s'}",
      style: Theme.of(context).textTheme.caption,
    );
  }

  Widget _buildCommentField(Comment comment, bool isLoadingReply, List<Comment> comments) {
    if(comment.replyTo!=null){
      return Container();
    }
    return CommentField(
      comment: comment,
      outfitId: widget.outfitId,
      userId: userId,
      pagesSinceOutfitScreen: widget.pagesSinceOutfitScreen,
      pagesSinceProfileScreen: widget.pagesSinceProfileScreen,
      isComingFromExploreScreen: widget.isComingFromExploreScreen,
      onStartReplyTo: _startReply,
      isLoadingReply: isLoadingReply,
      comments: comments,
      isShowingReplies: comment.commentId == showingRepliesForId,
      onUpdateReplies: (showingReplies) {
        if(showingReplies){
          setState(() => showingRepliesForId = comment.commentId);
        }else{
          setState(() => showingRepliesForId = null);
        }
      }
    );
  }

  _startReply(Comment comment) {
    setState(() {    
      replyingToComment=comment;
    });
  }

}