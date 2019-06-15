import 'dart:async';
import 'package:middleware/middleware.dart';

enum LogInMethod { email, facebook, twitter, google }
enum UserAccountStatus { LOGGED_OUT, PENDING_ONBOARDING, LOGGED_IN,}

abstract class UserRepository {  
  Future<String> existingAuthId();
  Future<bool> register(LogInForm logInForm);
  Future<bool> logIn(LogInForm logInForm);
  Future<bool> createAccount(OnboardUser onboardUser);

  Future<void> registerNotificationToken(String userId);
  Future<bool> loadNotifications(String userId);
  Future<bool> markNotificationsSeen(MarkNotificationsSeen markSeen);
  Stream<List<OutfitNotification>> getNotifications();
  
  Future<bool> followUser(FollowUser followUser);

  Future<bool> hasEmailVerified();
  Future<void> resendVerificationEmail([_]);
  Future<String> getVerificationEmail();
  Future<bool> checkUsernameExists(String username);

  Future<void> logOut();

  Future<bool> loadUserDetails(GetUser getUser);
  Stream<User> getUser(String userId);
}