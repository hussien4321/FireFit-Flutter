import 'package:firebase_auth/firebase_auth.dart';
import './auth_instance.dart';
import '../../../middleware/middleware.dart';
import 'dart:async';

class FacebookAuthInstance implements AuthInstance {
  
  final FirebaseAuth auth;

  const FacebookAuthInstance({
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
      FacebookAuthProvider.credential(fields.facebookToken)
    );
  }

}