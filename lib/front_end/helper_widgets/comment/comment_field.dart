import 'package:flutter/material.dart';
import '../../../../blocs/blocs.dart';
import '../../../../front_end/providers.dart';
import '../../../../front_end/helper_widgets.dart';
import '../../../../middleware/middleware.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../helpers/helpers.dart';

class CommentField extends StatefulWidget {
  final Comment comment;
  final int outfitId;
  final String userId;
  final int pagesSinceOutfitScreen;
  final int pagesSinceProfileScreen;
  final bool isComingFromExploreScreen;
  final ValueChanged<Comment> onStartReplyTo;
  final bool isLoadingReply;
  final List<Comment> comments;
  final bool isShowingReplies;
  final ValueChanged<bool> onUpdateReplies;

  CommentField({
    this.comment,
    this.outfitId,
    this.userId,
    this.pagesSinceOutfitScreen = 0,
    this.pagesSinceProfileScreen = 0,
    this.isComingFromExploreScreen = false,
    this.onStartReplyTo,
    this.isLoadingReply = false,
    this.comments,
    this.isShowingReplies = false,
    this.onUpdateReplies,
  });

  @override
  _CommentFieldState createState() => _CommentFieldState();
}

class _CommentFieldState extends State<CommentField> {
  CommentBloc _commentBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return Column(
      children: <Widget>[
        _originalComment(widget.comment),
        widget.isShowingReplies ? _replies() : Container(),
      ],
    );
  }

  _initBlocs() {
    if (_commentBloc == null) {
      _commentBloc = CommentBlocProvider.of(context);
    }
  }

  Widget _originalComment(Comment comment) {
    return Container(
      padding: EdgeInsets.only(bottom: 4.0, left: 8.0, right: 8.0),
      child: Column(
        children: <Widget>[
          InkWell(
            highlightColor: Colors.grey[700],
            onLongPress:
                isCurrentUser(comment) ? () => _confirmDelete(comment) : null,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ProfilePicWithShadow(
                    userId: comment.commenter.userId,
                    url: comment.commenter.profilePicUrl,
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
                        child: Text(comment.commenter.name,
                            style: Theme.of(context).textTheme.subtitle2),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.grey[350]),
                        width: double.infinity,
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          comment.text,
                        ),
                      ),
                    ],
                  ),
                ),
                comment.commentId <= 0
                    ? Container(
                        margin: EdgeInsets.only(top: 16, left: 8.0),
                        child: Center(child: CircularProgressIndicator()))
                    : Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                comment.isLiked
                                    ? FontAwesomeIcons.solidHeart
                                    : FontAwesomeIcons.heart,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _likeComment(comment),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.only(left: 48),
              width: double.infinity,
              child: Row(
                children: <Widget>[
                  Text(DateFormatter.dateToRecentFormat(comment.uploadDate),
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic)),
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                  ),
                  Text(
                    '${comment.likesCount} like${comment.likesCount == 1 ? '' : 's'}',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                  _replyButton(comment),
                  comment.repliesCount > 0
                      ? Expanded(child: _expandRepliesButton(comment))
                      : Container(),
                ],
              )),
        ],
      ),
    );
  }

  bool isCurrentUser(Comment comment) =>
      widget.userId == comment.commenter.userId;

  _confirmDelete(Comment comment) {
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
            }) ??
        false;
  }

  _likeComment(Comment comment) {
    CommentLike commentLike = CommentLike(
        comment: comment, outfitId: widget.outfitId, userId: widget.userId);
    _commentBloc.likeComment.add(commentLike);
  }

  Widget _replyButton(Comment comment) {
    return InkWell(
      onTap: () => _startReply(comment),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
        child: Text(
          'Reply',
          style: TextStyle(
              fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  _startReply(Comment comment) {
    widget.onStartReplyTo(comment);
  }

  Widget _expandRepliesButton(Comment comment) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        InkWell(
          onTap: () => _toggleReplies(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  widget.isShowingReplies
                      ? 'Hide replies'
                      : 'Show ${comment.repliesCount} Repl${comment.repliesCount == 1 ? 'y' : 'ies'}',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                Icon(
                  widget.isShowingReplies
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  _toggleReplies() {
    widget.onUpdateReplies(!widget.isShowingReplies);
    if (!widget.isShowingReplies) {
      _commentBloc.loadReplies.add(LoadComments(
        outfitId: widget.outfitId,
        userId: widget.userId,
        replyTo: widget.comment.commentId,
      ));
    }
  }

  Widget _replies() {
    List<Comment> replies = new List<Comment>.from(widget.comments);
    replies
        .removeWhere((comment) => comment.replyTo != widget.comment.commentId);
    replies.sort((commentA, commentB) =>
        commentA.uploadDate.compareTo(commentB.uploadDate));
    return Container(
      padding: const EdgeInsets.only(left: 8.0, right: 8),
      child: Column(
        children: replies.map((reply) => _replyField(reply)).toList()
          ..add(_replyEndTag(
            isLoading: widget.isLoadingReply,
            isComplete: replies.length >= widget.comment.repliesCount,
            reply: replies.length == 0 ? null : replies.last,
          )),
      ),
    );
  }

  Widget _replyField(Comment reply) {
    return Row(
      children: <Widget>[
        Container(
          width: 48,
          child: Center(
            child: Icon(
              Icons.arrow_forward_ios,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              InkWell(
                highlightColor: Colors.blueGrey,
                onLongPress:
                    isCurrentUser(reply) ? () => _confirmDelete(reply) : null,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ProfilePicWithShadow(
                        userId: reply.commenter.userId,
                        url: reply.commenter.profilePicUrl,
                        pagesSinceOutfitScreen: widget.pagesSinceOutfitScreen,
                        pagesSinceProfileScreen: widget.pagesSinceProfileScreen,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 8.0, bottom: 2.0),
                            child: Text(reply.commenter.name,
                                style: Theme.of(context).textTheme.subtitle2),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.grey[350]),
                            width: double.infinity,
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              reply.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                    reply.commentId <= 0
                        ? Container(
                            margin: EdgeInsets.only(top: 16, left: 8.0),
                            child: Center(child: CircularProgressIndicator()))
                        : Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    reply.isLiked
                                        ? FontAwesomeIcons.solidHeart
                                        : FontAwesomeIcons.heart,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => _likeComment(reply),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
              Container(
                  padding: EdgeInsets.only(left: 48),
                  width: double.infinity,
                  child: Row(
                    children: <Widget>[
                      Text(DateFormatter.dateToRecentFormat(reply.uploadDate),
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic)),
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                      ),
                      Text(
                        '${reply.likesCount} like${reply.likesCount == 1 ? '' : 's'}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _replyEndTag({Comment reply, bool isLoading, bool isComplete}) {
    if (isComplete) {
      return Container();
    }
    return Center(
        child: Container(
            margin: EdgeInsets.only(left: 48),
            padding: const EdgeInsets.all(8.0),
            child: isLoading ? _loadingTag() : _loadMoreTag(reply)));
  }

  Widget _loadingTag() {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'LOADING...',
              style: Theme.of(context).textTheme.subtitle1,
            )));
  }

  Widget _loadMoreTag(Comment reply) {
    return InkWell(
      onTap: () {
        _commentBloc.loadReplies.add(LoadComments(
          outfitId: widget.outfitId,
          userId: widget.userId,
          replyTo: widget.comment.commentId,
          startAfterComment: reply,
        ));
      },
      child: Center(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Load More',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Icon(Icons.add_circle_outline)
                ],
              ))),
    );
  }
}
