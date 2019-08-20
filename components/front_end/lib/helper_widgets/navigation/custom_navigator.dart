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

  static RouteTransitionsBuilder get _transitionsBuilder => (_, Animation<double> animation, __, Widget child) {
    return new SlideTransition(
    child: child,
      position: new Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(animation),
    );
  };
  
  static Future<T> goToProfileScreen<T extends Object>(BuildContext context, {
    String userId, 
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
      PageRouteBuilder(
        pageBuilder: (ctx, _, __) => ProfileScreen(
          userId: userId,
          pagesSinceOutfitScreen: pagesSinceOutfitScreen,
          pagesSinceProfileScreen: pagesSinceProfileScreen,
        ),
        transitionsBuilder: _transitionsBuilder,
        settings: RouteSettings(
          name: '/profile'
        ),
      ),
      (Route<dynamic> route) {
        bool removePrevious = numberOfPagesToRemove>0 || isComingFromExploreScreen;
        numberOfPagesToRemove--;
        bool isFirst = route.isFirst;
        return !removePrevious || isFirst; 
      },
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
      PageRouteBuilder(
        pageBuilder: (ctx, _, __) => OutfitDetailsScreen(
          outfitId: outfitId,
          loadOutfit: loadOutfit,
          pagesSinceOutfitScreen: pagesSinceOutfitScreen,
          pagesSinceProfileScreen: pagesSinceProfileScreen,
        ),
        transitionsBuilder: _transitionsBuilder,
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
   return Navigator.push(context, 
    PageRouteBuilder(
      pageBuilder: (ctx, _, __) => LogInScreen(
        isRegistering: isRegistering,
      ),
      transitionsBuilder: _transitionsBuilder,
      settings: RouteSettings(
        name: '/login'
      )
    ));
  }

  static Future<Null> goToEditUserScreen<T extends Object>(BuildContext context, {User user}) {
    return Navigator.push(context, 
      PageRouteBuilder(
        pageBuilder: (ctx, _, __) => EditUserScreen(
          user: user,
        ),
        transitionsBuilder: _transitionsBuilder,
        settings: RouteSettings(
          name: '/edit-user'
        )
      )
    );
  }

  static Future<Null> goToEditOutfitScreen<T extends Object>(BuildContext context, {Outfit outfit}) {
    return Navigator.push(context, PageRouteBuilder(
      pageBuilder: (ctx, _, __) => EditOutfitScreen(
        outfit: outfit,
      ),
      transitionsBuilder: _transitionsBuilder,
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
    return Navigator.push(context, PageRouteBuilder(
      pageBuilder: (ctx, _, __) => FollowUsersScreen(
        selectedUserId: selectedUserId,
        isFollowers: isFollowers,
        pagesSinceOutfitScreen: pagesSinceOutfitScreen,
        pagesSinceProfileScreen: pagesSinceProfileScreen,
      ),
      transitionsBuilder: _transitionsBuilder,
      settings: RouteSettings(
        name: '/follow-users'
      )
    ));
  }
  
  static Future<T> goToUploadOutfitScreen<T extends Object>(BuildContext context, {bool hasSubscription, ValueChanged<bool> onUpdateSubscriptionStatus, bool isOnWardrobePage}) {
    return Navigator.push(context, PageRouteBuilder(
      pageBuilder: (ctx, _, __) => UploadOutfitScreen(
        hasSubscription: hasSubscription,
        onUpdateSubscriptionStatus: onUpdateSubscriptionStatus,
        isOnWardrobePage: isOnWardrobePage,
      ),
      transitionsBuilder: _transitionsBuilder,
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
    return Navigator.push(context, PageRouteBuilder(
      pageBuilder: (ctx, _, __) => CommentsScreen(
        focusComment: focusComment,
        outfitId: outfitId,
        loadOutfit: loadOutfit,
        pagesSinceOutfitScreen: pagesSinceOutfitScreen,
        pagesSinceProfileScreen: pagesSinceProfileScreen,
        isComingFromExploreScreen: isComingFromExploreScreen,
      ),
      transitionsBuilder: _transitionsBuilder,
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
    return Navigator.push(context, PageRouteBuilder(
      pageBuilder: (ctx, _, __) => StyleSelectorScreen(),
      transitionsBuilder: _transitionsBuilder,
      settings: RouteSettings(
        name: '/style-selector'
      )
    ));
  }

  static Future<T> goToSubscriptionDetailsScreen<T extends Object>(BuildContext context, {int initialPage = 0, bool hasSubscription, ValueChanged<bool> onUpdateSubscriptionStatus}) {
    return Navigator.push(context, MaterialPageRoute(
      builder: (ctx) => SubscriptionDetailsScreen(
        initialPage: initialPage,
        hasSubscription: hasSubscription,
        onUpdateSubscriptionStatus: onUpdateSubscriptionStatus,
      ),
      settings: RouteSettings(
        name: '/subscription'
      )
    ));
  }

  static Future<T> goToFindUsersScreen<T extends Object>(BuildContext context) {
    return Navigator.push(context, MaterialPageRoute(
      builder: (ctx) => FindUsersScreen(),
      settings: RouteSettings(
        name: '/find-users'
      )
    ));
  }

  static Future<T> goToLookbookScreen<T extends Object>(BuildContext context, {Lookbook lookbook}) {
    return Navigator.push(context, PageRouteBuilder(
      pageBuilder: (ctx, _, __) => LookbookScreen(
        lookbook: lookbook
      ),
      transitionsBuilder: _transitionsBuilder,
      settings: RouteSettings(
        name: '/lookbook'
      )
    ));
  }

  static Future<T> goToFeedbackScreen<T extends Object>(BuildContext context) {
    return Navigator.push(context, PageRouteBuilder(
      pageBuilder: (ctx, _, __) => FeedbackScreen(),
      transitionsBuilder: _transitionsBuilder,
      settings: RouteSettings(
        name: '/feedback'
      )
    ));
  }

  static Future<T> goToFAQScreen<T extends Object>(BuildContext context) {
    return Navigator.push(context, PageRouteBuilder(
      pageBuilder: (ctx, _, __) => FAQScreen(),
      transitionsBuilder: _transitionsBuilder,
      settings: RouteSettings(
        name: '/faq'
      )
    ));
  }
  static Future<T> goToDeleteAccountScreen<T extends Object>(BuildContext context) {
    return Navigator.push(context, PageRouteBuilder(
      pageBuilder: (ctx, _, __) => DeleteAccountScreen(),
      transitionsBuilder: _transitionsBuilder,
      settings: RouteSettings(
        name: '/delete-account'
      )
    ));
  }

  
  static Future<T> goToPageAtRoot<T extends Object>(BuildContext context, String name) {
    return Navigator.pushNamedAndRemoveUntil(context,
      name,
      (route) => false
    );
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