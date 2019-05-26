import 'dart:async';
import 'package:middleware/middleware.dart';

enum LogInMethod { email, facebook, twitter, google }
enum UserAccountStatus { LOGGED_OUT, PENDING_ONBOARDING, LOGGED_IN,}

abstract class UserRepository {  
  Future<String> existingAuthId();
  Future<bool> register(LogInForm logInData);
  Future<bool> logIn(LogInForm logInData);
  Future<bool> createAccount(OnboardUser onboardingData);

  Future<bool> hasEmailVerified();
  Future<void> resendVerificationEmail([_]);
  Future<String> getVerificationEmail();
  Future<bool> checkUsernameExists(String username);

  Future<void> logOut();

  Stream<User> getCurrentUser(String userId);
}