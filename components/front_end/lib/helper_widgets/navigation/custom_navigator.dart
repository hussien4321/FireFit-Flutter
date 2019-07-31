import 'package:flutter/material.dart';
import 'package:front_end/screens.dart';
import 'package:middleware/middleware.dart';
import 'dart:async';
import 'package:front_end/helper_widgets.dart';
import 'package:page_transition/page_transition.dart';

class CustomNavigator {

  //TODO: GET ROUTE STACK FROM OBSERVER TO DETERMINE IF IT NEEDS TO REWIND
  //TODO: REMOVE ALL REFERENCES WHEN THAT IS IMPLEMENTED
  //CURRENT PROBLEM, INSTEAD OF REMOVING ALL PREVIOUS ROUTES, WE SHOULD COUNT THE NUMBER OF PAGES SINCE LAST OUTFIT/PROFILE AND THEN ONLY GO BACK THAT MANY

  static Future<T> goToProfileScreen<T extends Object>(BuildContext context, {
    String userId, 
    String heroTag,
    int pagesSinceOutfitScreen = 0, 
    int pagesSinceProfileScreen = 0,
    bool isComingFromExploreScreen = false, 
  }) {
    pagesSinceProfileScreen += pagesSinceProfileScreen>0 ? 1 : 0;
    // print('goToProfileScreen pagesSinceProfileScreen:$pagesSinceProfileScreen pagesSinceOutfitScreen:$pagesSinceOutfitScreen');
    int numberOfPagesToRemove = pagesSinceProfileScreen;
    if(numberOfPagesToRemove>0){
      pagesSinceOutfitScreen -= pagesSinceProfileScreen;
      if(pagesSinceOutfitScreen < 0){
        pagesSinceOutfitScreen = 0;
      }
      pagesSinceProfileScreen = 0;
    }
    // print('goToProfileScreen END pagesSinceProfileScreen:$pagesSinceProfileScreen pagesSinceOutfitScreen:$pagesSinceOutfitScreen');
    return Navigator.pushAndRemoveUntil(context, 
      MaterialPageRoute(
        builder: (ctx) => ProfileScreen(
          userId: userId,
          heroTag: heroTag,
          pagesSinceOutfitScreen: pagesSinceOutfitScreen,
          pagesSinceProfileScreen: pagesSinceProfileScreen,
        ),
        settings: RouteSettings(
          name: '/profile'
        )
      ),
      (Route<dynamic> route) {
        bool removePrevious = numberOfPagesToRemove>0 || isComingFromExploreScreen;
        numberOfPagesToRemove--;
        bool isFirst = route.isFirst;
        return !removePrevious || isFirst; 
      }
    );
  } 

  static Future<T> goToOutfitDetailsScreen<T extends Object>(BuildContext context, {
    int outfitId, 
    bool loadOutfit = false, 
    int pagesSinceOutfitScreen = 0, 
    int pagesSinceProfileScreen = 0,
    bool isComingFromExploreScreen = false, 
  }) {
    pagesSinceOutfitScreen += pagesSinceOutfitScreen>0 ? 1 : 0;
    // print('goToOutfitDetailsScreen pagesSinceProfileScreen:$pagesSinceProfileScreen pagesSinceOutfitScreen:$pagesSinceOutfitScreen');
    int numberOfPagesToRemove = pagesSinceOutfitScreen;
    if(numberOfPagesToRemove>0){
      pagesSinceProfileScreen -= pagesSinceOutfitScreen;
      if(pagesSinceProfileScreen < 0){
        pagesSinceProfileScreen= 0;
      }
      pagesSinceOutfitScreen= 0;
    }
    // print('goToOutfitDetailsScreen END pagesSinceProfileScreen:$pagesSinceProfileScreen pagesSinceOutfitScreen:$pagesSinceOutfitScreen');
    return Navigator.pushAndRemoveUntil(context, 
      MaterialPageRoute(
        builder: (ctx) => OutfitDetailsScreen(
          outfitId: outfitId,
          loadOutfit: loadOutfit,
          pagesSinceOutfitScreen: pagesSinceOutfitScreen,
          pagesSinceProfileScreen: pagesSinceProfileScreen,
        ),
        settings: RouteSettings(
          name: '/outfit'
        )
      ),
      (Route<dynamic> route) {
        bool removePrevious = numberOfPagesToRemove>0 || isComingFromExploreScreen;
        numberOfPagesToRemove--;
        bool isFirst = route.isFirst;
        return !removePrevious || isFirst; 
      }
    );
  } 

  static Future<T> goToLogInScreen<T extends Object>(BuildContext context, {bool isRegistering = false}) {
   return Navigator.push(context, MaterialPageRoute(
      builder: (ctx) => LogInScreen(
        isRegistering: isRegistering,
      ),
      settings: RouteSettings(
        name: '/login'
      )
    ));
  }

  static Future<Null> goToEditUserScreen<T extends Object>(BuildContext context, {User user}) {
    return Navigator.push(context, MaterialPageRoute(
      builder: (ctx) => EditUserScreen(
        user: user,
      ),
      settings: RouteSettings(
        name: '/edit-user'
      )
    ));
  }

  static Future<Null> goToEditOutfitScreen<T extends Object>(BuildContext context, {Outfit outfit}) {
    return Navigator.push(context, MaterialPageRoute(
      builder: (ctx) => EditOutfitScreen(
        outfit: outfit,
      ),
      settings: RouteSettings(
        name: '/edit-outfit'
      )
    ));
  }

  static Future<T> goToFollowUsersScreen<T extends Object>(BuildContext context, {
    bool isFollowers, 
    String selectedUserId, 
    int pagesSinceOutfitScreen = 0,
    int pagesSinceProfileScreen = 0
  }) {
    pagesSinceOutfitScreen += pagesSinceOutfitScreen>0 ? 1 :0;
    // print('goToFollowUsersScreen pagesSinceProfileScreen:$pagesSinceProfileScreen pagesSinceOutfitScreen:$pagesSinceOutfitScreen');
    return Navigator.push(context, MaterialPageRoute(
      builder: (context) => FollowUsersScreen(
        selectedUserId: selectedUserId,
        isFollowers: isFollowers,
        pagesSinceOutfitScreen: pagesSinceOutfitScreen,
        pagesSinceProfileScreen: pagesSinceProfileScreen,
      ),
      settings: RouteSettings(
        name: '/follow-users'
      )
    ));
  }
  
  static Future<T> goToUploadOutfitScreen<T extends Object>(BuildContext context) {
    return Navigator.push(context, MaterialPageRoute(
      builder: (context) => UploadOutfitScreen(),
      settings: RouteSettings(
        name: '/upload-outfit'
      )
    ));
  }

  static Future<T> goToCommentsScreen<T extends Object>(BuildContext context, {int outfitId, bool focusComment = false, bool loadOutfit = false, 
    int pagesSinceOutfitScreen = 0, 
    int pagesSinceProfileScreen = 0,
    bool isComingFromExploreScreen = false,
  }) {
    pagesSinceProfileScreen += pagesSinceProfileScreen>0 ? 1 :0;
    // print('goToCommentsScreen pagesSinceProfileScreen:$pagesSinceProfileScreen pagesSinceOutfitScreen:$pagesSinceOutfitScreen');
    return Navigator.push(context, MaterialPageRoute(
      builder: (ctx) => CommentsScreen(
        focusComment: focusComment,
        outfitId: outfitId,
        loadOutfit: loadOutfit,
        pagesSinceOutfitScreen: pagesSinceOutfitScreen,
        pagesSinceProfileScreen: pagesSinceProfileScreen,
        isComingFromExploreScreen: isComingFromExploreScreen,
      ),
      settings: RouteSettings(
        name: '/comments'
      )
    ));
  }

  static Future<T> goToSettingsScreen<T extends Object>(BuildContext context) {
    return Navigator.push(context, MaterialPageRoute(
      builder: (ctx) => SettingsScreen(),
      settings: RouteSettings(
        name: '/settings'
      )
    ));
  }

  static Future<T> goToStyleSelectorScreen<T extends Object>(BuildContext context) {
    return Navigator.push(context, MaterialPageRoute(
      builder: (context) => StyleSelectorScreen(),
      settings: RouteSettings(
        name: '/style-selector'
      )
    ));
  }

  static Future<T> goToSubscriptionDetailsScreen<T extends Object>(BuildContext context) {
    return Navigator.push(context, MaterialPageRoute(
      builder: (context) => SubscriptionDetailsScreen(),
      settings: RouteSettings(
        name: '/subscription'
      )
    ));
  }

  static Future<T> goToFindUsersScreen<T extends Object>(BuildContext context) {
    return Navigator.push(context, MaterialPageRoute(
      builder: (context) => FindUsersScreen(),
      settings: RouteSettings(
        name: '/find-users'
      )
    ));
  }

  static Future<T> goToLookbookScreen<T extends Object>(BuildContext context, {Lookbook lookbook}) {
    return Navigator.push(context, MaterialPageRoute(
      builder: (context) => LookbookScreen(
        lookbook: lookbook
      ),
      settings: RouteSettings(
        name: '/lookbook'
      )
    ));
  }

  static Future<T> goToFeedbackScreen<T extends Object>(BuildContext context) {
    return Navigator.push(context, MaterialPageRoute(
      builder: (context) => FeedbackScreen(),
      settings: RouteSettings(
        name: '/feedback'
      )
    ));
  }

  static Future<T> goToFAQScreen<T extends Object>(BuildContext context) {
    return Navigator.push(context, MaterialPageRoute(
      builder: (context) => FAQScreen(),
      settings: RouteSettings(
        name: '/faq'
      )
    ));
  }
  static Future<T> goToDeleteAccountScreen<T extends Object>(BuildContext context) {
    return Navigator.push(context, MaterialPageRoute(
      builder: (context) => DeleteAccountScreen(),
      settings: RouteSettings(
        name: '/delete-account'
      )
    ));
  }
}

class SlideRightRoute extends PageRouteBuilder {
  
  final Widget page;
  final RouteSettings settings;

  SlideRightRoute({this.page, this.settings}) : super(
    settings: settings,
    pageBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
    ) => page,
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child
    ) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    ),
  );

}