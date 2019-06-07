import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:middleware/middleware.dart';

class UserBloc {
  final UserRepository repository;

  List<StreamSubscription<dynamic>> _subscriptions;

  final _currentUserController =  BehaviorSubject<BehaviorSubject<User>>(seedValue: BehaviorSubject<User>(seedValue: null));
  Stream<User> get currentUser => _currentUserController.value; 
  final _loadCurrentUserController = PublishSubject<Null>();
  Sink<String> get loadCurrentUser => _loadCurrentUserController; 

  final _selectedUserController = BehaviorSubject<Stream<User>>();
  Stream<User> get selectedUser => _selectedUserController.value;
  final _selectUserController = PublishSubject<String>();
  Sink<String> get selectUser => _selectUserController; 

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

  
  final _onboardController = PublishSubject<OnboardUser>();
  Sink<OnboardUser> get onboard => _onboardController;

  final _loadingController = PublishSubject<bool>();
  Observable<bool> get isLoading => _loadingController.stream;
  final _errorController = PublishSubject<String>();
  Observable<String> get hasError => _errorController.stream;
  final _successController = PublishSubject<bool>();
  Observable<bool> get isSuccessful => _successController.stream;

  final _resendEmailController = PublishSubject<void>();
  Sink<void> get resendVerificationEmail => _resendEmailController;
  final _refreshVerificationEmailController = PublishSubject<void>();
  Sink<void> get refreshVerificationEmail => _refreshVerificationEmailController;
  final _isEmailVerifiedController = PublishSubject<bool>();
  Observable<bool> get isEmailVerified => _isEmailVerifiedController;
  final _verificationEmailController = BehaviorSubject<String>();
  Observable<String> get verificationEmail => _verificationEmailController;

  final _checkUsernameController = PublishSubject<String>();
  Sink<String> get checkUsername => _checkUsernameController;
  final _isUsernameTakenController = PublishSubject<bool>();
  Observable<bool> get isUsernameTaken => _isUsernameTakenController;


  UserBloc(this.repository) {
    _subscriptions = <StreamSubscription<dynamic>>[
      _logInController.listen(_logInUser),
      _registerController.listen(_registerUser),
      _logOutController.listen(_logOutUser),
      _onboardController.listen(_onboardUser),
      _checkUsernameController.stream.listen((t) => _isUsernameTakenController.add(null)),
      _checkUsernameController.stream.debounce(Duration(milliseconds: 500)).listen(_refreshUsernameCheck),
      _refreshVerificationEmailController.stream.listen(_refreshVerifiedCheck),
      _resendEmailController.stream.listen(repository.resendVerificationEmail),
      _selectUserController.listen(_getUserStream),
      _loadCurrentUserController.listen(_loadCurrentUser),
    ];
    _loadCurrentUser();
    _accountStatusController = Observable.combineLatest2<String, BehaviorSubject<User>, UserAccountStatus>(existingAuthId, _currentUserController, _redirectPath).asBroadcastStream().debounce(Duration(milliseconds: 300));
    _resetCurrentUserStatus();
  }

  UserAccountStatus _redirectPath(String authId, BehaviorSubject<User> currentUserStream){
    User currentUser = currentUserStream.value;
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

  _resetCurrentUserStatus() async {
      String userId = await repository.existingAuthId();
      _existingAuthController.add(userId);
      await _loadCurrentUser();
  }

  _logInUser(LogInForm logInForm) async {
    _loadingController.add(true);
    bool success = await repository.logIn(logInForm);
    _loadingController.add(false);
    if(success){
      await _resetCurrentUserStatus();
      _successController.add(true);
    }else{
      _errorController.add('Failed to log in');
    }
  } 

  _registerUser(LogInForm logInForm) async {
    _loadingController.add(true);
    bool success = await repository.register(logInForm);
    _loadingController.add(false);
    if(success){
      await _resetCurrentUserStatus();
      _successController.add(true);
    }else{
      _errorController.add('Failed to register, this is probably because the account already exists.');
    }
  } 
  
  _logOutUser([_]) async {
      _existingAuthController.add(null);
      await repository.logOut();
  }


  _onboardUser(OnboardUser onboardUser) async {
    _loadingController.add(true);
    bool success = await repository.createAccount(onboardUser);
    _loadingController.add(false);
    if(success){
      _successController.add(true);
    }else{
      _errorController.add('Failed to create, this might be because the username has now been taken.');
    }
  } 

  _refreshVerifiedCheck([_]) async {
    bool isEmailVerified = await repository.hasEmailVerified();
    String email = await repository.getVerificationEmail();
    _isEmailVerifiedController.add(isEmailVerified);
    _verificationEmailController.add(email);
  }

  _refreshUsernameCheck(String username) async {
    _loadingController.add(true);
    bool usernameExists = await repository.checkUsernameExists(username);
    _loadingController.add(false);
    _isUsernameTakenController.add(usernameExists);
  }

  _getUserStream(String userId) async {
    _loadingController.add(true);
    await repository.loadUserDetails(userId);
    _selectedUserController.add(repository.getUser(userId));
    _loadingController.add(false);
  }

  _loadCurrentUser([_]) async {
    _loadingController.add(true);

    String userId = await existingAuthId.first;
    await repository.loadUserDetails(userId);

    BehaviorSubject<User> userStream = BehaviorSubject<User>();
    userStream.addStream(repository.getUser(userId));
    await userStream.isEmpty; 
    _loadingController.add(false);
    _currentUserController.add(userStream);
    
  }

  void dispose() {
    _currentUserController.close();
    _existingAuthController.close();
    _loadCurrentUserController.close();
    _selectedUserController.close();
    _selectUserController.close();
    _loadingController.close();
    _logInController.close();
    _logOutController.close();
    _registerController.close();
    _errorController.close();
    _subscriptions.forEach((subscription) => subscription.cancel());
  }
}