import 'dart:async';
import 'package:middleware/middleware.dart';

enum LogInMethod { email, facebook, twitter, google }
enum UserAccountStatus { LOGGED_OUT, PENDING_ONBOARDING, LOGGED_IN,}

abstract class UserRepository {  
  Future<String> existingAuthId();
  Future<bool> register(LogInForm logInForm);
  Future<bool> logIn(LogInForm logInForm);
  Future<bool> createAccount(OnboardUser onboardUser);
  Future<bool> editUser(EditUser editUser);

  Future<void> registerNotificationToken(String userId);
  Future<void> updateNotificationToken(UpdateToken updateToken);
  Future<bool> loadNotifications(LoadNotifications loadNotifications);
  Future<bool> loadMoreNotifications(LoadNotifications loadNotifications);
  Future<bool> markNotificationsSeen(MarkNotificationsSeen markSeen);
  Stream<List<OutfitNotification>> getNotifications();
  
  Future<bool> followUser(FollowUser followUser);
  Future<bool> loadFollowers(LoadUsers loadUsers);
  Future<bool> loadFollowing(LoadUsers loadUsers);
  Future<bool> loadMoreFollowing(LoadUsers loadUsers);
  Future<bool> loadMoreFollowers(LoadUsers loadUsers);
  
  Future<bool> hasEmailVerified();
  Future<void> resendVerificationEmail([_]);
  Future<String> getVerificationEmail();
  Future<bool> checkUsernameExists(String username);

  Future<void> logOut();
  Future<bool> deleteUser(String userId);

  Future<bool> loadUserDetails(LoadUser loadUser, SearchModes searchMode);
  Stream<User> getUser(SearchModes searchMode);
  Stream<List<User>> getUsers(SearchModes searchMode);
}