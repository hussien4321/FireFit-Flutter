import 'package:firebase_auth/firebase_auth.dart';
import 'package:middleware/middleware.dart';
import 'dart:async';

abstract class AuthInstance {  

  final FirebaseAuth auth;

  const AuthInstance({
    this.auth
  });
  
  Future<FirebaseUser> register({
    LogInFields fields,
  });
  
  Future<FirebaseUser> signIn({
    LogInFields fields,
  });
}
