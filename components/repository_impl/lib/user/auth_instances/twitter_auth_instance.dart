import 'package:firebase_auth/firebase_auth.dart';
import './auth_instance.dart';
import 'package:middleware/middleware.dart';

class TwitterAuthInstance implements AuthInstance {
  
  final FirebaseAuth auth;

  const TwitterAuthInstance({
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
      TwitterAuthProvider.getCredential(
        authToken: fields.twitterToken,
        authTokenSecret: fields.twitterTokenSecret
      )
    );
  }

}