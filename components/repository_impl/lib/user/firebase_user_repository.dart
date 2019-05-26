// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import './auth_instances.dart';
import 'package:repository_impl/repository_impl.dart';
import 'package:middleware/middleware.dart';
import 'package:helpers/helpers.dart';
import 'package:path/path.dart';


class FirebaseUserRepository implements UserRepository {
  static const String dbPath = 'users';
  static const String findUserByIdQueryPath = 'user_data.user_id';
  
  final FirebaseAuth auth;
  final CloudFunctions cloudFunctions;
  final FirebaseImageUploader imageUploader;
  final CachedUserRepository cache;

  const FirebaseUserRepository({
    this.auth, 
    this.cloudFunctions,
    this.imageUploader,
    this.cache,
  });


  Future<String> existingAuthId() async {
    print('start');
    await Future.delayed(Duration(seconds: 3));
    print('done');
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
      .then((user) => _saveCurrentUser(user))
      .catchError((e) => false);
  }
  
  Future<bool> logIn(LogInForm logInData) async {
    AuthInstance specificAuthInstance = _getSpecificAuthInstance(logInData.method);
    return specificAuthInstance.signIn(fields: logInData.fields) 
      .then((user) async {
        return _saveCurrentUser(user);
      })
      .catchError((Exception err) {
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

  Future<bool> _saveCurrentUser(FirebaseUser user) async {
    User currentUser = await _getUserAccountIfExisting(user.uid);
    print('currentUser:$currentUser');
    if(currentUser !=null){
      await cache.addUser(currentUser);
      return true;
    }
    return false;
  }


  Future<User> _getUserAccountIfExisting(String userId) {
    return cloudFunctions.call(functionName: 'getUser', parameters: {'user_id': userId})
    .then((res) {
      if(res.isEmpty){
        return null;
      }
      Map<String, dynamic> data = Map<String, dynamic>.from(res[0]);
      return User.fromMap(data);
    })
    .catchError((err) {
      print('err:$err');
      return null;
    });

  }

  Future<bool> createAccount(OnboardUser onboardUser) async {

    return cloudFunctions.call(functionName: 'createUser', parameters: onboardUser.toJson())
    .then((res) async {
      String userId = res['ref'];
      String fileName = _generateFileName(onboardUser.profilePic, userId);
      await imageUploader.uploadImage(fileName, onboardUser.profilePic);
      final user = await auth.currentUser();
      return _saveCurrentUser(user);
    })
    .catchError((err) => false);
  }

  _generateFileName(String imagePath, String userId){
    final String uuid = Uuid().generateV4();
    return 'profile:$userId:${uuid.toString()}${extension(imagePath)}';
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
      return res['ref'].toString() == 'true';
    })
    .catchError((err) => true);
  } 

  Future<void> logOut() async {
    await auth.signOut();
    await cache.deleteAll();
  }

  Stream<User> getCurrentUser(String userId) {
    return cache.getUser(userId);
  }



}

