import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:middleware/middleware.dart';

class UserBloc {
  final UserRepository repository;

  List<StreamSubscription<dynamic>> _subscriptions;

  final _currentUserController = BehaviorSubject<User>(seedValue: null);
  Stream<User> get currentUser => _currentUserController.stream; 

  final _existingAuthController = BehaviorSubject<String>(seedValue: null);
  Stream<String> get existingAuthId => _existingAuthController.stream; 

  Stream<UserAccountStatus> get accountStatus => Observable.combineLatest2<String, User, UserAccountStatus>(existingAuthId, currentUser, _redirectPath).asBroadcastStream().debounce(Duration(seconds: 1));


  final _registerController = PublishSubject<LogInForm>();
  Sink<LogInForm> get register => _registerController;

  final _logInController = PublishSubject<LogInForm>();
  Sink<LogInForm> get logIn => _logInController;


  final _loadingController = PublishSubject<bool>();
  Observable<bool> get loadingStatus => _loadingController.stream;

  final _errorController = PublishSubject<bool>();
  Observable<bool> get errors => _errorController.stream;



  UserBloc(this.repository) {
    _subscriptions = <StreamSubscription<dynamic>>[
      // _existingAuthController.listen(_updateCurrentUser),
    ];
    _existingAuthController.addStream(repository.existingAuthId().asStream());
    _currentUserController.addStream(repository.getCurrentUser(_existingAuthController.value));
    

  }

  UserAccountStatus _redirectPath(String authId, User currentUser){
    _loadingController.add(true);
    if(authId == null){
      return UserAccountStatus.LOGGED_OUT;
    }else{
      if(currentUser == null){
        return UserAccountStatus.PENDING_ONBOARDING;
      }else{
        return UserAccountStatus.LOGGED_IN;
      }
    }
  }

  _updateCurrentUser(String userId){
    if(userId == null ){
      _currentUserController.add(null);
    }else{
      _currentUserController.addStream(repository.getCurrentUser(userId));
    }
  }
  

  void dispose() {
    _currentUserController.close();
    _existingAuthController.close();
    _loadingController.close();
    _logInController.close();
    _registerController.close();
    _errorController.close();
    _subscriptions.forEach((subscription) => subscription.cancel());
  }
}