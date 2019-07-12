import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import './auth_instances.dart';
import 'package:repository_impl/repository_impl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:middleware/middleware.dart';
import 'package:helpers/helpers.dart';
import 'package:path/path.dart';
import 'package:meta/meta.dart';

class FirebaseUserRepository implements UserRepository {
  static const String dbPath = 'users';
  static const String findUserByIdQueryPath = 'user_data.user_id';
  
  final FirebaseAuth auth;
  final CloudFunctions cloudFunctions;
  final FirebaseImageUploader imageUploader;
  final CachedOutfitRepository outfitCache;
  final CachedUserRepository userCache;
  final FirebaseMessaging messaging;


  FirebaseUserRepository({
    @required this.auth, 
    @required this.cloudFunctions,
    @required this.imageUploader,
    @required this.outfitCache,
    @required this.userCache,
    @required this.messaging,
  });

  Future<String> existingAuthId() async {
    final user = await auth.currentUser();
    final hasAuth = user!=null;
    if(!hasAuth){
      await userCache.clearEverything();
      return null;
    }
    return user.uid;
  }

  
  Future<bool> register(LogInForm logInData) async {
    AuthInstance specificAuthInstance = _getSpecificAuthInstance(logInData.method);
    if(logInData.fields.password != logInData.fields.passwordConfirmation){
      return false;
    }
    return specificAuthInstance.register(fields: logInData.fields) 
      .then((user) => true)
      .catchError((e) => false);
  }
  
  Future<bool> logIn(LogInForm logInData) {
    AuthInstance specificAuthInstance = _getSpecificAuthInstance(logInData.method);
    return specificAuthInstance.signIn(fields: logInData.fields) 
      .then((user) async {
        await _loadCurrentUser(user);
        return true;
      })
      .catchError((err) {
        print('catchError :$err');
        return false;
      });
  }

  AuthInstance _getSpecificAuthInstance(LogInMethod method) {
    switch (method) {
      case LogInMethod.email:
        return EmailAuthInstance(auth: auth);
      case LogInMethod.google:
        return GoogleAuthInstance(auth: auth);
      case LogInMethod.twitter:
        return TwitterAuthInstance(auth: auth);
      case LogInMethod.facebook:
        return FacebookAuthInstance(auth: auth);
      default:
        return null;
    }
  }

  Future<bool> createAccount(OnboardUser onboardUser) async {
  return cloudFunctions.getHttpsCallable(functionName: 'createUser').call(onboardUser.toJson())
  .then((res) async {
      final user = await auth.currentUser();
      String userId = user.uid;
      String fileName = _generateFileName(onboardUser.profilePicUrl, userId);
      await imageUploader.uploadImage(onboardUser.profilePicUrl, fileName);

      return _checkImageUploaded(userId);
    })
    .catchError((err) {
      print('failed creation!');
      print(err.message);
      return false;
    });
  }

  _generateFileName(String imagePath, String userId){
    final String uuid = Uuid().generateV4();
    return 'temp/profile:$userId:${uuid.toString()}${extension(imagePath)}';
  }
  List<User> _resToUserList(HttpsCallableResult res){
    return List<User>.from(res.data['res'].map((data){
      Map<String, dynamic> formattedDoc = Map<String, dynamic>.from(data);
      return User.fromMap(formattedDoc);
    }).toList());
  }
  
  Future<bool> _checkImageUploaded(String userId) async {
    LoadUser loadUser = LoadUser(
      userId: userId,
      currentUserId: userId,
      searchMode: SearchModes.MINE,
    );
    for(int i = 0; i < AppConfig.NUMBER_OF_POLL_ATTEMPTS; i++){
      print('polling for profile pic attempt: $i time=${DateTime.now()}');
      bool success = await _getExistingUser(loadUser);
      if(success){
        return true;
      }
      await Future.delayed(Duration(milliseconds: AppConfig.DURATION_PER_POLL_ATTEMPT));
    }
    return false;
  }

  Future<bool> _getExistingUser(LoadUser loadUser) async {
    return cloudFunctions.getHttpsCallable(functionName: 'getUser').call(loadUser.toJson())
    .then((res) async {
      List<User> userList = _resToUserList(res);
      if(userList.isEmpty){
        return false;
      }
      User user = userList.first;
      await userCache.addUser(user, loadUser.searchMode);
      return true;
    })
    .catchError((err) {
      return false;
    });
  }

  Future<bool> _loadCurrentUser(FirebaseUser user) {
    return loadUserDetails(
      LoadUser(
        userId: user.uid,
        currentUserId: user.uid,
      ),
      SearchModes.MINE,
    );
  }

  Future<bool> loadUserDetails(LoadUser loadUser, SearchModes searchMode) async {
    await userCache.clearUsers(searchMode);
    User user = await _getUserAccountIfExisting(loadUser);
    if(user !=null){
      await userCache.addUser(user, searchMode);
      return true;
    }
    return false;
  }


  Future<User> _getUserAccountIfExisting(LoadUser loadUser) {
    return cloudFunctions.getHttpsCallable(functionName: 'getUser').call(loadUser.toJson())
    .then((res) {
      List<User> userList = _resToUserList(res);
      if(userList.isEmpty){
        return null;
      }
      return userList.first;
    })
    .catchError((err) {
      return null;
    });
  }

  Future<bool> editUser(EditUser editUser) {
    return cloudFunctions.getHttpsCallable(functionName: 'editUser').call(editUser.toJson())
    .then((res) async {
      bool success = res.data['res'];
      if(!success){
        return false;
      }
      if(editUser.hasNewProfilePic){
        String fileName = _generateFileName(editUser.profilePicUrl, editUser.userId);
        await imageUploader.uploadImage(editUser.profilePicUrl, fileName);
        return _checkImageUpdated(editUser.userId, editUser.initialProfilePicUrl);
      }else{
        userCache.updateUserBiometrics(editUser);
        return true;
      }
    })
    .catchError((err) => false);
  }


  Future<bool> _checkImageUpdated(String userId, String currentProfilePic) async {
    LoadUser loadUser = LoadUser(
      userId: userId,
      currentUserId: userId,
      searchMode: SearchModes.MINE,
    );
    for(int i = 0; i < AppConfig.NUMBER_OF_POLL_ATTEMPTS; i++){
      print('polling for profile pic attempt: $i time=${DateTime.now()}');
      bool success = await _getUserNewProfilePic(loadUser, currentProfilePic);
      if(success){
        return true;
      }
      await Future.delayed(Duration(milliseconds: AppConfig.DURATION_PER_POLL_ATTEMPT));
    }
    return false;
  }

  Future<bool> _getUserNewProfilePic(LoadUser loadUser, String currentProfilePicUrl) async {
    return cloudFunctions.getHttpsCallable(functionName: 'getUser').call(loadUser.toJson())
    .then((res) async {
      List<User> userList = _resToUserList(res);
      if(userList.isEmpty){
        return false;
      }
      User user = userList.first;
      if(user.profilePicUrl != currentProfilePicUrl){
        await userCache.addUser(user, loadUser.searchMode);
        return true;
      }else{
        return false;
      }
    })
    .catchError((err) {
      return false;
    });
  }

  Future<bool> hasEmailVerified() async {
    (await auth.currentUser()).reload();
    final user = await auth.currentUser();
    bool hasEmailCreds = user.providerData.map((provider) => provider.providerId=='password').contains(true);
    return !hasEmailCreds || user.isEmailVerified; 
  }

  Future<String> getVerificationEmail() async {
    final user = await auth.currentUser();
    bool hasEmailCreds = user.providerData.map((provider) => provider.providerId=='password').contains(true);
    if(!hasEmailCreds){
      return '';
    }
    return user.providerData.where((provider) => provider.providerId == 'password').toList()[0].email;
  }

  Future<void> resendVerificationEmail([_]) async {
    final user = await auth.currentUser();
    await user.sendEmailVerification();
  }

  Future<bool> checkUsernameExists(String username) async {
    return cloudFunctions.getHttpsCallable(functionName: 'checkUsernameExists').call({
      'username' : username
    })
    .then((res) {
      return res.data['res'].toString() == 'true';
    })
    .catchError((err) {
      return true;
    });
  } 

  Future<void> registerNotificationToken(String userId) async {
    String notificationToken = await messaging.getToken();
    messaging.requestNotificationPermissions();
    return cloudFunctions.getHttpsCallable(functionName: 'registerNotificationToken').call({
      'user_id' : userId,
      'notification_token' : notificationToken
    });
  }

  Future<void> logOut() async {
    messaging.deleteInstanceID();
    userCache.clearEverything();
    auth.signOut();
  }

  Future<bool> deleteUser(String userId) async {
    return cloudFunctions.getHttpsCallable(functionName: 'deleteUser').call({
      'user_id' : userId,
    }).then((res) {
      bool success = res.data['res'] == true;
      if(success){
        messaging.deleteInstanceID();
        userCache.clearEverything();
        auth.signOut();
      }
      return success;
    }).catchError((err){
      return false;
    });
  }

  Stream<User> getUser(SearchModes searchMode) => userCache.getUser(searchMode);
  
  Stream<List<User>> getUsers(SearchModes searchMode) => userCache.getUsers(searchMode);

  Stream<List<OutfitNotification>> getNotifications() => outfitCache.getNotifications();

  Future<bool> loadNotifications(LoadNotifications loadNotifications) async {
    if(loadNotifications.isLive){
      DateTime latestNotificationTime = await outfitCache.getLatestNotificationTime();
      loadNotifications.lastNotificationCreatedAt = latestNotificationTime;
    }else{
      outfitCache.clearNotifications();
    }
    return loadMoreNotifications(loadNotifications);
  }
  
  Future<bool> loadMoreNotifications(LoadNotifications loadNotifications) async {
    return cloudFunctions.getHttpsCallable(functionName: 'getNotifications').call(loadNotifications.toJson())
    .then((res) async {
      List<OutfitNotification> notifications = List<OutfitNotification>.from(res.data['res'].map((data){
        Map<String, dynamic> formattedDoc = Map<String, dynamic>.from(data);
        return OutfitNotification.fromMap(formattedDoc);
      }).toList());
      notifications.forEach((notification) {
        outfitCache.addNotification(notification);
        if(loadNotifications.isLive){
          outfitCache.updateLiveNotification(notification);
        }
      });
      if(loadNotifications.isLive){
        userCache.incrementUserNewNotifications(notifications.length);
      }
      return true;
    })
    .catchError((err) {
      print(err);
      return false;
    });
  }

  Future<bool> markNotificationsSeen(MarkNotificationsSeen markSeen) async {
    await userCache.markNotificationsSeen(markSeen);
    return cloudFunctions.getHttpsCallable(functionName: 'markNotificationsSeen').call(markSeen.toJson())
    .then((res) {
      return true;
    })
    .catchError((err) {
      print(err);
      return false;
    });
  }

  Future<bool> followUser(FollowUser followUser) async {
    await userCache.followUser(followUser);
    return cloudFunctions.getHttpsCallable(functionName: 'followUser').call(followUser.toJson())
    .then((res) => res.data['res'] == true)
    .catchError((err) {
      print(err);
      return false;
    });
  }
  
  Future<bool> loadFollowing(LoadUsers loadUsers) => _loadFollowUsers(loadUsers, functionName: 'getFollowing');
  Future<bool> loadFollowers(LoadUsers loadUsers) => _loadFollowUsers(loadUsers, functionName: 'getFollowers');
  
  Future<bool> _loadFollowUsers(LoadUsers loadUsers, {String functionName}){
    userCache.clearUsers(loadUsers.searchMode);
    return _loadMoreFollowUsers(loadUsers, functionName:functionName);
  }

  Future<bool> loadMoreFollowing(LoadUsers loadUsers) => _loadMoreFollowUsers(loadUsers, functionName: 'getFollowing');
  Future<bool> loadMoreFollowers(LoadUsers loadUsers) => _loadMoreFollowUsers(loadUsers, functionName: 'getFollowers');
  
  Future<bool> _loadMoreFollowUsers(LoadUsers loadUsers, {String functionName}){  
    return cloudFunctions.getHttpsCallable(functionName: functionName).call(loadUsers.toJson())
    .then((res) async {
      List<User> users = _resToUserList(res);
      users.forEach((user) => userCache.addUser(user, loadUsers.searchMode));
      return true;
    })
    .catchError((err) {
      print('failed on func $functionName');
      print(err.message);
      return false;
    });

  }
}

