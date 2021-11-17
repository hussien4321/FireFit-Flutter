import 'package:firebase_auth/firebase_auth.dart';
import './auth_instance.dart';
import '../../../middleware/middleware.dart';
import 'dart:async';

class TwitterAuthInstance implements AuthInstance {
  
  final FirebaseAuth auth;

  const TwitterAuthInstance({
    this.auth
  });

  Future<UserCredential> register({
    LogInFields fields
  }){
    return null;
  }

  Future<UserCredential> signIn({
    LogInFields fields
  }){
    return auth.signInWithCredential(
      TwitterAuthProvider.credential(accessToken: fields.twitterToken, secret: fields.twitterTokenSecret)
    );
  }

}