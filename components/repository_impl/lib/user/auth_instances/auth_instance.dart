import 'package:firebase_auth/firebase_auth.dart';
import 'package:middleware/middleware.dart';

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
