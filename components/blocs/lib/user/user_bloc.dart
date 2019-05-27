import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:middleware/middleware.dart';

class UserBloc {
  final UserRepository repository;

  List<StreamSubscription<dynamic>> _subscriptions;

  BehaviorSubject<User> _currentUserController = BehaviorSubject<User>(seedValue: null);
  Stream<User> get currentUser => _currentUserController.stream; 

  final _existingAuthController = BehaviorSubject<String>(seedValue: null);
  Stream<String> get existingAuthId => _existingAuthController.stream; 

  Observable<UserAccountStatus> _accountStatusController;
  Stream<UserAccountStatus> get accountStatus => _accountStatusController;

  final _registerController = PublishSubject<LogInForm>();
  Sink<LogInForm> get register => _registerController;

  final _logInController = PublishSubject<LogInForm>();
  Sink<LogInForm> get logIn => _logInController;

  final _logOutController = PublishSubject<void>();
  Sink<void> get logOut => _logOutController;


  final _loadingController = PublishSubject<bool>();
  Observable<bool> get isLoading => _loadingController.stream;

  final _errorController = PublishSubject<String>();
  Observable<String> get hasError => _errorController.stream;

  final _successController = PublishSubject<bool>();
  Observable<bool> get isSuccessful => _successController.stream;



  UserBloc(this.repository) {
    _subscriptions = <StreamSubscription<dynamic>>[
      _logInController.listen(_logInUser),
      _registerController.listen(_registerUser),
      _logOutController.listen(_logOutUser),
    ];
    _accountStatusController = Observable.combineLatest2<String, User, UserAccountStatus>(existingAuthId, _currentUserController, _redirectPath).asBroadcastStream().debounce(Duration(milliseconds: 300));
    _resetAuth();
    _currentUserController.addStream(repository.getCurrentUser());
  }

  UserAccountStatus _redirectPath(String authId, User currentUser){
    if(authId == null){
      print('LOGGED OUT');
      return UserAccountStatus.LOGGED_OUT;
    }else{
      if(currentUser == null){
        print('ONBOARDING');
        return UserAccountStatus.PENDING_ONBOARDING;
      }else{
        print('LOGGED IN');
        return UserAccountStatus.LOGGED_IN;
      }
    }
  }

  _logInUser(LogInForm logInForm) async {
    _loadingController.add(true);
    bool success = await repository.logIn(logInForm);
    _loadingController.add(false);
    if(success){
      _successController.add(true);
      _resetAuth();
    }else{
      _errorController.add('Failed to log in');
    }
  } 

  _registerUser(LogInForm logInForm) async {
    _loadingController.add(true);
    bool success = await repository.register(logInForm);
    _loadingController.add(false);
    if(success){
      _successController.add(true);
      _resetAuth();
    }else{
      _errorController.add('Failed to register, this is probably because the account already exists.');
    }
  } 

  _resetAuth() async {
      String userId = await repository.existingAuthId();
      _existingAuthController.add(userId);
  }
  
  _logOutUser([_]) async {
      _existingAuthController.add(null);
      await repository.logOut();
  }



  void dispose() {
    _currentUserController.close();
    _existingAuthController.close();
    _loadingController.close();
    _logInController.close();
    _logOutController.close();
    _registerController.close();
    _errorController.close();
    _subscriptions.forEach((subscription) => subscription.cancel());
  }
}