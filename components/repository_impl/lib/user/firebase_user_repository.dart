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
  final CachedUserRepository cache;
  final FirebaseMessaging messaging;


  FirebaseUserRepository({
    @required this.auth, 
    @required this.cloudFunctions,
    @required this.imageUploader,
    @required this.cache,
    @required this.messaging,
  });

  Future<String> existingAuthId() async {
    final user = await auth.currentUser();
    final hasAuth = user!=null;
    if(!hasAuth){
      await cache.deleteAll();
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
    return loadUserDetails(user.uid);
  }

  Future<bool> loadUserDetails(String userId) async {
    User currentUser = await _getUserAccountIfExisting(userId);
    if(currentUser !=null){
      await cache.addUser(currentUser, isCurrentUser: true);
      return true;
    }
    return false;
  }


  Future<User> _getUserAccountIfExisting(String userId) {
    return cloudFunctions.call(functionName: 'getUser', parameters: {'user_id': userId})
    .then((res) {
      final result = res['res'];
      if(res.length == 0) {
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
  return cloudFunctions.call(functionName: 'createUser', parameters: onboardUser.toJson())
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
    return cloudFunctions.call(functionName: 'checkUsernameExists', parameters: {
      'username' : username
    })
    .then((res) {
      return res['res'].toString() == 'true';
    })
    .catchError((err) {
      return true;
    });
  } 

  Future<void> registerNotificationToken(String userId) async {
    String notificationToken = await messaging.getToken();
    messaging.requestNotificationPermissions();
    return cloudFunctions.call(functionName: 'registerNotificationToken', parameters: {
      'user_id' : userId,
      'notification_token' : notificationToken
    });
  }

  Future<void> logOut() async {
    messaging.deleteInstanceID();
    cache.deleteAll();
    auth.signOut();
  }

  Stream<User> getUser(String userId) => cache.getUser(userId);
}

