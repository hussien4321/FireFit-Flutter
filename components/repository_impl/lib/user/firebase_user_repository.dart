// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

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
      await userCache.deleteAll();
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

  Future<bool> _loadCurrentUser(FirebaseUser user) {
    return loadUserDetails(GetUser(
      userId: user.uid,
      currentUserId: user.uid,
    ));
  }

  Future<bool> loadUserDetails(GetUser getUser) async {
    User currentUser = await _getUserAccountIfExisting(getUser);
    if(currentUser !=null){
      await userCache.addUser(currentUser, isCurrentUser: true);
      return true;
    }
    return false;
  }


  Future<User> _getUserAccountIfExisting(GetUser getUser) {
    return cloudFunctions.getHttpsCallable(functionName: 'getUser').call(getUser.toJson())
    .then((res) {
      final result = res.data['res'];
      if(res.data.length == 0) {
        return null;
      }
      Map<String, dynamic> formattedDoc = Map<String, dynamic>.from(result[0]);
      return User.fromMap(formattedDoc);
    })
    .catchError((err) {
      return null;
    });

  }

  Future<bool> createAccount(OnboardUser onboardUser) async {
  return cloudFunctions.getHttpsCallable(functionName: 'createUser').call(onboardUser.toJson())
  .then((res) async {
      final user = await auth.currentUser();
      String userId = user.uid;
      String fileName = _generateFileName(onboardUser.profilePicUrl, userId);
      await imageUploader.uploadImage(onboardUser.profilePicUrl, fileName);
      return _loadCurrentUser(user);
    })
    .catchError((err) => false);
  }

  _generateFileName(String imagePath, String userId){
    final String uuid = Uuid().generateV4();
    return 'temp/profile:$userId:${uuid.toString()}${extension(imagePath)}';
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
    userCache.deleteAll();
    auth.signOut();
  }

  Stream<User> getUser(String userId) => userCache.getUser(userId);

  Stream<List<OutfitNotification>> getNotifications() => outfitCache.getNotifications();

  Future<bool> loadNotifications(String userId) {
    outfitCache.clearNotifications();
    return cloudFunctions.getHttpsCallable(functionName: 'getNotifications').call({
      'user_id': userId
    })
    .then((res) async {
      List<OutfitNotification> notifications = List<OutfitNotification>.from(res.data['res'].map((data){
        Map<String, dynamic> formattedDoc = Map<String, dynamic>.from(data);
        return OutfitNotification.fromMap(formattedDoc);
      }).toList());
      notifications.forEach((notification) => outfitCache.insertNotification(notification));
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
    .then((res) => res.data['res'])
    .catchError((err) {
      print(err);
      return false;
    });
  }

  Future<bool> followUser(FollowUser followUser) async {
    print('isFollowing: ${followUser.followed.isFollowing}');
    await userCache.followUser(followUser);
    print('isFollowing: ${followUser.followed.isFollowing}');
    return cloudFunctions.getHttpsCallable(functionName: 'followUser').call(followUser.toJson())
    .then((res) => res.data['res'] == true)
    .catchError((err) {
      print(err);
      return false;
    });
  }
}

