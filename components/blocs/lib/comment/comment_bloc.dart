import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:middleware/middleware.dart'
;
class CommentBloc {

  final OutfitRepository repository;
  List<StreamSubscription<dynamic>> _subscriptions;

  final _addCommentController = PublishSubject<AddComment>();
  Sink<AddComment> get addComment => _addCommentController;

  final _commentsController = BehaviorSubject<List<Comment>>(seedValue: []);
  Stream<List<Comment>> get comments => _commentsController.stream; 
  
  final _loadCommentsController = PublishSubject<LoadComments>();
  Sink<LoadComments> get loadComments => _loadCommentsController; 
  
  final _likeCommentController = PublishSubject<CommentLike>();
  Sink<CommentLike> get likeComment => _likeCommentController; 
  
  final _deleteCommentController = PublishSubject<DeleteComment>();
  Sink<DeleteComment> get deleteComment => _deleteCommentController; 
  
  final _loadingController = PublishSubject<bool>();
  Observable<bool> get isLoading => _loadingController.stream;

  final _successController = PublishSubject<bool>();
  Observable<bool> get isSuccessful => _successController.stream;

  final _errorController = PublishSubject<String>();
  Observable<String> get hasError => _errorController.stream;
  
  CommentBloc(this.repository) {
    _commentsController.addStream(repository.getComments());
    _subscriptions = <StreamSubscription<dynamic>>[
      _loadCommentsController.listen(_loadComments),
      _likeCommentController.listen(_likeComment),
      _addCommentController.listen(_addComment),
      _deleteCommentController.listen(_deleteComment),
    ];
  }


  _loadComments(LoadComments loadComments) async {
    _loadingController.add(true);
    final success = await repository.loadComments(loadComments);
    _loadingController.add(false);
    _successController.add(success);
    if(!success){
      _errorController.add("Failed to load comments");
    }
  }

  _likeComment(CommentLike commentLike) async {
    final success = await repository.likeComment(commentLike);
    if(!success){
      _errorController.add("Failed to like comment");
    }

  }

  _addComment(AddComment comment) async {
    final success = await repository.addComment(comment);
    if(!success){
      _errorController.add("Failed to comment on outfit");
    }
  }

  _deleteComment(DeleteComment comment) => repository.deleteComment(comment);
  
  void dispose() {
    _addCommentController.close();
    _loadCommentsController.close();
    _commentsController.close();
    _likeCommentController.close();
    _deleteCommentController.close();
    _loadingController.close();
    _successController.close();
    _errorController.close();
    _subscriptions.forEach((subscription) => subscription.cancel());
  }
}