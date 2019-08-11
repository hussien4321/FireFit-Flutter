import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:middleware/middleware.dart';
import 'package:blocs/blocs.dart';

class UserBloc {
  final UserRepository _repository;
  final OutfitRepository _outfitRepository;
  final Preferences _preferences;

  List<StreamSubscription<dynamic>> _subscriptions;

  final _currentUserController =  BehaviorSubject<User>();
  Stream<User> get currentUser => _currentUserController; 
  final _loadCurrentUserController = PublishSubject<Null>();
  Sink<String> get loadCurrentUser => _loadCurrentUserController; 

  final _selectedUserController = BehaviorSubject<User>();
  Stream<User> get selectedUser => _selectedUserController;
  final _searchedUserController = BehaviorSubject<User>();
  Stream<User> get searchedUser => _searchedUserController;
  final _selectUserController = PublishSubject<String>();
  Sink<String> get selectUser => _selectUserController; 
  final _searchUserController = PublishSubject<String>();
  Sink<String> get searchUser => _searchUserController; 

  final _markWardrobeSeenController = PublishSubject<String>();
  Sink<String> get markWardrobeSeen => _markWardrobeSeenController; 

  final _followersController = BehaviorSubject<List<User>>();
  Stream<List<User>> get followers => _followersController;
  final _followingController = BehaviorSubject<List<User>>();
  Stream<List<User>> get following => _followingController; 
  final _loadFollowersController = PublishSubject<LoadUsers>();
  Sink<LoadUsers> get loadFollowers => _loadFollowersController; 
  final _loadFollowingController = PublishSubject<LoadUsers>();
  Sink<LoadUsers> get loadFollowing => _loadFollowingController; 

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

  final _sendFeedbackController = PublishSubject<FeedbackRequest>();
  Sink<FeedbackRequest> get sendFeedback => _sendFeedbackController;

  final _reportUserController = PublishSubject<ReportForm>();
  Sink<ReportForm> get reportUser => _reportUserController;
  
  final _onboardController = PublishSubject<OnboardUser>();
  Sink<OnboardUser> get onboard => _onboardController;
  
  final _isBackgroundLoadingController = PublishSubject<bool>();
  Observable<bool> get isBackgroundLoading => _isBackgroundLoadingController.stream;

  final _noUserFoundController = PublishSubject<bool>();
  Observable<bool> get noUserFound => _noUserFoundController.stream;

  final _loadingController = PublishSubject<bool>();
  Observable<bool> get isLoading => _loadingController.stream;
  final _isLoadingFollowsController = PublishSubject<bool>();
  Observable<bool> get isLoadingFollows => _isLoadingFollowsController.stream;
  final _errorController = PublishSubject<String>();
  Observable<String> get hasError => _errorController.stream;
  final _successController = PublishSubject<bool>();
  Observable<bool> get isSuccessful => _successController.stream;
  final _successMessageController = PublishSubject<String>();
  Observable<String> get successMessage => _successMessageController.stream;

  final _resendEmailController = PublishSubject<void>();
  Sink<void> get resendVerificationEmail => _resendEmailController;
  final _refreshVerificationEmailController = PublishSubject<void>();
  Sink<void> get refreshVerificationEmail => _refreshVerificationEmailController;
  final _isEmailVerifiedController = BehaviorSubject<bool>();
  BehaviorSubject<bool> get isEmailVerified => _isEmailVerifiedController;
  final _verificationEmailController = BehaviorSubject<String>();
  Observable<String> get verificationEmail => _verificationEmailController;

  final _checkUsernameController = PublishSubject<String>();
  Sink<String> get checkUsername => _checkUsernameController;
  final _isUsernameTakenController = PublishSubject<bool>();
  Observable<bool> get isUsernameTaken => _isUsernameTakenController;
  
  final _followUserController = PublishSubject<FollowUser>();
  Sink<FollowUser> get followUser => _followUserController;


  UserBloc(this._repository, this._outfitRepository, this._preferences) {
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
      _resendEmailController.stream.listen(_repository.resendVerificationEmail),
      _markWardrobeSeenController.listen(_repository.markWardrobeSeen),
      _selectUserController.listen(_loadSelectedUser),
      _searchUserController.distinct().listen(_loadSearchUser),
      _loadCurrentUserController.listen(_loadCurrentUser),
      _followUserController.listen(_followUser),
      _loadFollowersController.listen(_loadFollowers),
      _loadFollowingController.listen(_loadFollowing),
      _sendFeedbackController.listen(_sendFeedback),
      _reportUserController.listen(_reportUser),
    ];
    _selectedUserController.addStream(_repository.getUser(SearchModes.SELECTED));
    _searchedUserController.addStream(_repository.getUser(SearchModes.TEMP));
    _currentUserController.addStream(_repository.getUser(SearchModes.MINE));
    _followersController.addStream(_repository.getUsers(SearchModes.FOLLOWERS));
    _followingController.addStream(_repository.getUsers(SearchModes.FOLLOWING));
    _accountStatusController = Observable.combineLatest3<String, User, bool, UserAccountStatus>(existingAuthId, _currentUserController, _loadingController, _redirectPath).asBroadcastStream().debounce(Duration(milliseconds: 300));
    _resetCurrentUserStatus(isFirstTimeLoad: true);
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

  _resetCurrentUserStatus({bool isFirstTimeLoad = false}) async {
      String userId = await _repository.existingAuthId();
      _existingAuthController.add(userId);
      await _loadCurrentUser();
      if(isFirstTimeLoad && userId!=null){
        await _loadStartupStreams();
      }
  }

  _logInUser(LogInForm logInForm) async {
    _loadingController.add(true);
    bool success = await _repository.logIn(logInForm);
    if(success){
      await _resetCurrentUserStatus();
      await _loadFirstTimeStreams();
      await _loadStartupStreams();
    }
    _loadingController.add(false);
    if(success){
      _successController.add(true);
    }else{
      _errorController.add("Failed to log in, account details are incorrect");
    }
  } 

  _loadFirstTimeStreams() async {
    await _outfitRepository.clearLookbooks();
    bool sortBySize = await _preferences.getPreference(Preferences.LOOKBOOKS_SORT_BY_SIZE);
    _outfitRepository.loadLookbooks(LoadLookbooks(
      userId: _currentUserId,
      sortBySize: sortBySize,
    ));
    searchModesToNOTClearEachTime.forEach((searchMode) async {
      await _outfitRepository.clearOutfits(searchMode);
      bool sortByTop = await getSortByTop(searchMode);
      _outfitRepository.loadOutfits(LoadOutfits(
        userId: _currentUserId,
        searchMode: searchMode,
        sortByTop: sortByTop,
      ));
    });
  }

  Future<dynamic> getSortByTop(SearchModes searchMode) async {
    switch (searchMode) {
      case SearchModes.MINE:
        return _preferences.getPreference(Preferences.WARDROBE_SORT_BY_TOP);
      case SearchModes.EXPLORE:
        return _preferences.getPreference(Preferences.EXPLORE_PAGE_SORT_BY_TOP);
      default:
        return false;
    }
  }

  _loadStartupStreams() async {
    searchModesToClearOnStart.forEach((searchMode) async {
      await _outfitRepository.clearOutfits(searchMode);
      bool sortByTop = await getSortByTop(searchMode);
      OutfitFilters filters =OutfitFilters();
      if(searchMode ==SearchModes.EXPLORE){
        filters = OutfitFilters.fromMap(await _preferences.getPreference(Preferences.EXPLORE_PAGE_FILTERS));
      }
      _outfitRepository.loadOutfits(LoadOutfits(
        userId: _currentUserId,
        searchMode: searchMode,
        sortByTop: sortByTop,
        filters: filters,
      ));
    });
  }

  _registerUser(LogInForm logInForm) async {
    _loadingController.add(true);
    bool success = await _repository.register(logInForm);
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
      await _repository.logOut();
      _preferences.resetPreferences();
      _successMessageController.add("Sign out successful!");
  }

  _deleteUser([_]) async {
    _loadingController.add(true);
    bool success = await _repository.deleteUser(_currentUserId);
    _loadingController.add(false);
    if(success){
      _existingAuthController.add(null);
      _successController.add(true);
    }else{
      _errorController.add('Failed to delete account');
    }
  }

  _editUser(EditUser editUser) async {
    _successController.add(true);
    _isBackgroundLoadingController.add(true);
    bool success = await _repository.editUser(editUser);
    _isBackgroundLoadingController.add(false);
    if(success){
      _successMessageController.add("Profile edited!");
    }else{
      _errorController.add('Failed to edit user');
    }
  }


  _onboardUser(OnboardUser onboardUser) async {
    _loadingController.add(true);
    bool success = await _repository.createAccount(onboardUser);
    _loadingController.add(false);
    if(success){
      await _loadFirstTimeStreams();
      await _loadStartupStreams();
      _successController.add(true);
    }else{
      _errorController.add('Failed to create, this might be because the username has now been taken.');
    }
  } 

  _refreshVerifiedCheck([_]) async {
    bool isEmailVerified = await _repository.hasEmailVerified();
    String email = await _repository.getVerificationEmail();
    if(email==''){
      email = await _repository.getVerificationEmail();
    }
    _isEmailVerifiedController.add(isEmailVerified);
    _verificationEmailController.add(email);
  }

  _refreshUsernameCheck(String username) async {
    _loadingController.add(true);
    bool usernameExists = await _repository.checkUsernameExists(username);
    _loadingController.add(false);
    _isUsernameTakenController.add(usernameExists);
  }

  String get _currentUserId => _existingAuthController.value;

  _loadSelectedUser(String userId) async {
    _loadingController.add(true);
    try{
      await _repository.loadUserDetails(
        LoadUser(
          userId: userId,
          currentUserId: _currentUserId
        ),
        SearchModes.SELECTED
      );
    } on NoItemFoundException catch (_) {
      _noUserFoundController.add(true);
    }
    _loadingController.add(false);
  }

  _loadSearchUser(String username) async {
    _loadingController.add(true);
    await _repository.loadUserDetails(
      LoadUser(
        username: username,
        currentUserId: _currentUserId
      ),
      SearchModes.TEMP
    );
    _loadingController.add(false);
  }

  _loadCurrentUser([_]) async {
    _loadingController.add(true);
    await _repository.loadUserDetails(
      LoadUser(
        userId: _currentUserId,
        currentUserId: _currentUserId
      ),
      SearchModes.MINE
    );
    _loadingController.add(false);
  }

  _followUser(FollowUser followUser) async {
    bool isFollowing = followUser.followed.isFollowing;
    bool success = await _repository.followUser(followUser);
    if(success){
      _successMessageController.add(isFollowing ?  "User unfollowed!" : "Now following user!");
    }else{
      _errorController.add("Failed to follow user");
    }
  }

  _loadFollowers(LoadUsers loadUsers) async {
    loadUsers.searchMode = SearchModes.FOLLOWERS;
    loadUsers.currentUserId = _currentUserId;
    _isLoadingFollowsController.add(true);
    loadUsers.startAfterUser == null ? await _repository.loadFollowers(loadUsers) : await _repository.loadMoreFollowers(loadUsers);
    _isLoadingFollowsController.add(false);
  }
  _loadFollowing(LoadUsers loadUsers) async {
    loadUsers.searchMode = SearchModes.FOLLOWING;
    loadUsers.currentUserId = _currentUserId;
    _isLoadingFollowsController.add(true);
    loadUsers.startAfterUser == null ? await _repository.loadFollowing(loadUsers) : await _repository.loadMoreFollowing(loadUsers);
    _isLoadingFollowsController.add(false);
  }

  _sendFeedback(FeedbackRequest feedbackRequest) async {
    _loadingController.add(true);
    bool success = await _repository.sendFeedback(feedbackRequest);
    _loadingController.add(false);
    _successController.add(success);
    if(!success){
      _errorController.add("Failed to send feedback");
    }
  }

  _reportUser(ReportForm reportForm) async {
    bool success = await _repository.reportUser(reportForm);
    if(success){
      _successMessageController.add("Thanks for letting us know!");
    }else{
      _errorController.add("Failed to send feedback");
    }
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
    _searchedUserController.close();
    _followUserController.close();
    _selectUserController.close();
    _searchUserController.close();
    _sendFeedbackController.close();
    _reportUserController.close();
    _noUserFoundController.close();
    _checkUsernameController.close();
    _refreshVerificationEmailController.close();
    _resendEmailController.close();
    _markWardrobeSeenController.close();
    _loadingController.close();
    _logInController.close();
    _logOutController.close();
    _editUserController.close();
    _deleteUserController.close();
    _registerController.close();
    _errorController.close();
    _isBackgroundLoadingController.close();
    _isLoadingFollowsController.close();
    _successMessageController.close();
    _subscriptions.forEach((subscription) => subscription.cancel());
  }
}