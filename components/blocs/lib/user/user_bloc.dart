import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:middleware/middleware.dart';

class UserBloc {
  final UserRepository repository;

  List<StreamSubscription<dynamic>> _subscriptions;

  final _currentUserController =  BehaviorSubject<User>();
  Stream<User> get currentUser => _currentUserController; 
  final _loadCurrentUserController = PublishSubject<Null>();
  Sink<String> get loadCurrentUser => _loadCurrentUserController; 

  final _selectedUserController = BehaviorSubject<User>();
  Stream<User> get selectedUser => _selectedUserController;
  final _selectUserController = PublishSubject<String>();
  Sink<String> get selectUser => _selectUserController; 


  final _followersController = BehaviorSubject<List<User>>();
  Stream<List<User>> get followers => _followersController;
  final _followingController = BehaviorSubject<List<User>>();
  Stream<List<User>> get following => _followingController;
  final _loadFollowersController = PublishSubject<String>();
  Sink<String> get loadFollowers => _loadFollowersController; 
  final _loadFollowingController = PublishSubject<String>();
  Sink<String> get loadFollowing => _loadFollowingController; 

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
  final _editUserController = PublishSubject<EditUser>();
  Sink<EditUser> get editUser => _editUserController;
  final _deleteUserController = PublishSubject<void>();
  Sink<void> get deleteUser => _deleteUserController;

  
  final _onboardController = PublishSubject<OnboardUser>();
  Sink<OnboardUser> get onboard => _onboardController;

  final _loadingController = PublishSubject<bool>();
  Observable<bool> get isLoading => _loadingController.stream;
  final _isLoadingFollowsController = PublishSubject<bool>();
  Observable<bool> get isLoadingFollows => _isLoadingFollowsController.stream;
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
  
  final _followUserController = PublishSubject<FollowUser>();
  Sink<FollowUser> get followUser => _followUserController;


  UserBloc(this.repository) {
    _subscriptions = <StreamSubscription<dynamic>>[
      _logInController.listen(_logInUser),
      _registerController.listen(_registerUser),
      _logOutController.listen(_logOutUser),
      _deleteUserController.listen(_deleteUser),
      _editUserController.listen(_editUser),
      _onboardController.listen(_onboardUser),
      _checkUsernameController.stream.listen((t) => _isUsernameTakenController.add(null)),
      _checkUsernameController.stream.debounce(Duration(milliseconds: 500)).listen(_refreshUsernameCheck),
      _refreshVerificationEmailController.stream.listen(_refreshVerifiedCheck),
      _resendEmailController.stream.listen(repository.resendVerificationEmail),
      _selectUserController.distinct().listen(_loadSelectedUser),
      _loadCurrentUserController.listen(_loadCurrentUser),
      _followUserController.listen(_followUser),
      _loadFollowersController.listen(_loadFollowers),
      _loadFollowingController.listen(_loadFollowing),
    ];
    _loadCurrentUser();
    _selectedUserController.addStream(repository.getUser(SearchModes.SELECTED));
    _currentUserController.addStream(repository.getUser(SearchModes.MINE));
    _followersController.addStream(repository.getUsers(SearchModes.FOLLOWERS));
    _followingController.addStream(repository.getUsers(SearchModes.FOLLOWING));
    _accountStatusController = Observable.combineLatest3<String, User, bool, UserAccountStatus>(existingAuthId, _currentUserController, _loadingController, _redirectPath).asBroadcastStream().debounce(Duration(milliseconds: 300));
    _resetCurrentUserStatus();
  }

  UserAccountStatus _redirectPath(String authId, User currentUser, bool isLoading){
    if(isLoading){
      return null;
    }
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

  _deleteUser([_]) async {
    _loadingController.add(true);
    bool success = await repository.deleteUser(_currentUserId);
    _loadingController.add(false);
    if(success){
      _existingAuthController.add(null);
      _successController.add(true);
    }else{
      _errorController.add('Failed to delete account');
    }
  }

  _editUser(EditUser editUser) async {
    _loadingController.add(true);
    bool success = await repository.editUser(editUser);
    _loadingController.add(false);
    _successController.add(success);
    if(!success){
      _errorController.add('Failed to edit user');
    }
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

  String get _currentUserId => _existingAuthController.value;

  _loadSelectedUser(String userId) async {
    _loadingController.add(true);
    await repository.loadUserDetails(
      LoadUser(
        userId: userId,
        currentUserId: _currentUserId
      ),
      SearchModes.SELECTED
    );
    _loadingController.add(false);
  }

  _loadCurrentUser([_]) async {
    _loadingController.add(true);
    await repository.loadUserDetails(
      LoadUser(
        userId: _currentUserId,
        currentUserId: _currentUserId
      ),
      SearchModes.MINE
    );
    _loadingController.add(false);
  }

  _followUser(FollowUser followUser) async {
    bool success = await repository.followUser(followUser);
    if(!success){
      _errorController.add("Failed to complete task");
    }
  }

  _loadFollowers(String userId) async {
    _isLoadingFollowsController.add(true);
    await repository.loadFollowers(
      LoadUser(
        userId: userId,
        currentUserId: _currentUserId,
        searchMode: SearchModes.FOLLOWERS
      )
    );
    _isLoadingFollowsController.add(false);
  }
  _loadFollowing(String userId) async {
    _isLoadingFollowsController.add(true);
    await repository.loadFollowing(
      LoadUser(
        userId: userId,
        currentUserId: _currentUserId,
        searchMode: SearchModes.FOLLOWING
      ),
    );
    _isLoadingFollowsController.add(false);
  }

  void dispose() {
    _currentUserController.close();
    _existingAuthController.close();
    _followersController.close();
    _followingController.close();
    _loadFollowersController.close();
    _loadFollowingController.close();
    _loadCurrentUserController.close();
    _selectedUserController.close();
    _followUserController.close();
    _selectUserController.close();
    _loadingController.close();
    _logInController.close();
    _logOutController.close();
    _editUserController.close();
    _deleteUserController.close();
    _registerController.close();
    _errorController.close();
    _isLoadingFollowsController.close();
    _subscriptions.forEach((subscription) => subscription.cancel());
  }
}