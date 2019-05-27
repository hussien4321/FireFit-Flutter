import 'dart:async';
import 'package:middleware/middleware.dart';

enum LogInMethod { email, facebook, twitter, google }
enum UserAccountStatus { LOGGED_OUT, PENDING_ONBOARDING, LOGGED_IN,}

abstract class UserRepository {  
  Future<String> existingAuthId();
  Future<bool> register(LogInForm logInForm);
  Future<bool> logIn(LogInForm logInForm);
  Future<bool> createAccount(OnboardUser onboardUser);

  Future<bool> hasEmailVerified();
  Future<void> resendVerificationEmail([_]);
  Future<String> getVerificationEmail();
  Future<bool> checkUsernameExists(String username);

  Future<void> logOut();

  Stream<User> getCurrentUser();
}