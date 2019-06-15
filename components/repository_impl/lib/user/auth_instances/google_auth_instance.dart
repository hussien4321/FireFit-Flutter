import 'package:firebase_auth/firebase_auth.dart';
import './auth_instance.dart';
import 'package:middleware/middleware.dart';

class GoogleAuthInstance implements AuthInstance {
  
  final FirebaseAuth auth;

  const GoogleAuthInstance({
    this.auth
  });

  Future<FirebaseUser> register({
    LogInFields fields
  }){
    return null;
  }

  Future<FirebaseUser> signIn({
    LogInFields fields
  }){
    return auth.signInWithCredential(
      GoogleAuthProvider.getCredential(
        accessToken: fields.googleAccessToken,
        idToken: fields.googleIdToken
      )
    );
  }

}