import 'package:firebase_auth/firebase_auth.dart';
import './auth_instance.dart';
import '../../../middleware/middleware.dart';
import 'dart:async';

class EmailAuthInstance implements AuthInstance {
  
  final FirebaseAuth auth;

  const EmailAuthInstance({
    this.auth
  });

  Future<UserCredential> register({
    LogInFields fields
  }){
    return auth.createUserWithEmailAndPassword(
      email: fields.email,
      password: fields.password
    );
  }

  Future<UserCredential> signIn({
    LogInFields fields
  }){
    return auth.signInWithEmailAndPassword(
      email: fields.email,
      password: fields.password
    );
  }

}