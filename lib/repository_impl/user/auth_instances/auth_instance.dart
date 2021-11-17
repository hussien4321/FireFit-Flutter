import 'package:firebase_auth/firebase_auth.dart';
import '../../../middleware/middleware.dart';
import 'dart:async';

abstract class AuthInstance {  

  final FirebaseAuth auth;

  const AuthInstance({
    this.auth
  });
  
  Future<UserCredential> register({
    LogInFields fields,
  });
  
  Future<UserCredential> signIn({
    LogInFields fields,
  });
}
