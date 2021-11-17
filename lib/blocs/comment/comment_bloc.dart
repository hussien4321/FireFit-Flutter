import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../../../middleware/middleware.dart';
import 'dart:math';

class CommentBloc {

  final OutfitRepository repository;
  List<StreamSubscription<dynamic>> _subscriptions;

  final _addCommentController = PublishSubject<AddComment>();
  Sink<AddComment> get addComment => _addCommentController;

  final _commentsController = BehaviorSubject<List<Comment>>.seeded([]);
  Stream<List<Comment>> get comments => _commentsController.stream; 
  
  final _loadCommentsController = PublishSubject<LoadComments>();
  Sink<LoadComments> get loadComments => _loadCommentsController; 
  
  final _loadRepliesController = PublishSubject<LoadComments>();
  Sink<LoadComments> get loadReplies => _loadRepliesController; 
  
  final _likeCommentController = PublishSubject<CommentLike>();
  Sink<CommentLike> get likeComment => _likeCommentController; 
  
  final _deleteCommentController = PublishSubject<DeleteComment>();
  Sink<DeleteComment> get deleteComment => _deleteCommentController; 
  
  final _loadingController = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isLoading => _loadingController.stream;
  
  final _loadingReplyController = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isLoadingReply => _loadingReplyController.stream;

  final _successController = PublishSubject<bool>();
  Stream<bool> get isSuccessful => _successController.stream;
  final _successMessageController = PublishSubject<String>();
  Stream<String> get successMessage => _successMessageController.stream;

  final _errorController = PublishSubject<String>();
  Stream<String> get hasError => _errorController.stream;
  
  CommentBloc(this.repository) {
    _commentsController.addStream(repository.getComments());
    _subscriptions = <StreamSubscription<dynamic>>[
      _loadCommentsController.listen(_loadComments),
      _loadRepliesController.listen(_loadReplies),
      _likeCommentController.listen(_likeComment),
      _addCommentController.listen(_addComment),
      _deleteCommentController.listen(_deleteComment),
    ];
  }

  _loadComments(LoadComments loadComments) async {
    _loadingController.add(true);
    final success = loadComments.startAfterComment == null ? await repository.loadComments(loadComments) : await repository.loadMoreComments(loadComments);
    _loadingController.add(false);
    _successController.add(success);
    if(!success){
      _errorController.add("Failed to load comments");
    }
  }

  _loadReplies(LoadComments loadComments) async {
    _loadingReplyController.add(true);
    final success = await repository.loadMoreComments(loadComments);
    _loadingReplyController.add(false);
    _successController.add(success);
    if(!success){
      _errorController.add("Failed to load replies");
    }
  }

  _likeComment(CommentLike commentLike) async {
    final success = await repository.likeComment(commentLike);
    if(!success){
      _errorController.add("Failed to like comment");
    }

  }

  String get _generateRandomMessage {
    Random random =Random();
    List<String> messages = [
      "Thanks for commenting!",
      "We always love hearing your thoughts!",
      "Great advice!",
      "Keep on sharing!",
    ];
    return messages[random.nextInt(messages.length)];
      
  }
  _addComment(AddComment comment) async {
    final success = await repository.addComment(comment);
    if(success){
      _successMessageController.add(_generateRandomMessage);
    } else {
      _errorController.add("Failed to comment on outfit");
    }
  }

  _deleteComment(DeleteComment comment) async {
    bool success = await repository.deleteComment(comment);
    if(success){
      _successMessageController.add("Delete successful!");
    }
  }

  void dispose() {
    _addCommentController.close();
    _loadCommentsController.close();
    _loadRepliesController.close();
    _commentsController.close();
    _likeCommentController.close();
    _deleteCommentController.close();
    _loadingController.close();
    _loadingReplyController.close();
    _successController.close();
    _errorController.close();
    _successMessageController.close();
    _subscriptions.forEach((subscription) => subscription.cancel());
  }
}