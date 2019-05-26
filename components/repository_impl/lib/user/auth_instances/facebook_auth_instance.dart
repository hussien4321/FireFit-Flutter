import 'package:firebase_auth/firebase_auth.dart';
import './auth_instance.dart';
import 'package:middleware/middleware.dart';

class FacebookAuthInstance implements AuthInstance {
  
  final FirebaseAuth auth;

  const FacebookAuthInstance({
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
    return auth.signInWithFacebook(
      accessToken: fields.facebookToken
    );
  }

}