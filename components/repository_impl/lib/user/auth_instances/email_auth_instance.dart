import 'package:firebase_auth/firebase_auth.dart';
import './auth_instance.dart';
import 'package:middleware/middleware.dart';

class EmailAuthInstance implements AuthInstance {
  
  final FirebaseAuth auth;

  const EmailAuthInstance({
    this.auth
  });

  Future<FirebaseUser> register({
    LogInFields fields
  }){
    return auth.createUserWithEmailAndPassword(
      email: fields.email,
      password: fields.password
    );
  }

  Future<FirebaseUser> signIn({
    LogInFields fields
  }){
    return auth.signInWithEmailAndPassword(
      email: fields.email,
      password: fields.password
    );
  }

}