import 'package:flutter/material.dart';
import 'package:front_end/screens.dart';
import 'package:middleware/middleware.dart';
import 'dart:async';
import 'package:front_end/helper_widgets.dart';

class CustomNavigator {

  //TODO: GET ROUTE STACK FROM OBSERVER TO DETERMINE IF IT NEEDS TO REWIND

  static Future<T> goToProfileScreen<T extends Object>(BuildContext context, bool removePrevious, {String userId, String heroTag}) {
    return Navigator.pushAndRemoveUntil(context, 
      MaterialPageRoute(
        builder: (ctx) => ProfileScreen(
          userId: userId, 
          heroTag: heroTag,
        ),
        settings: RouteSettings(
          name: '/profile'
        )
      ),
      (Route<dynamic> route) {
        bool isFirst = route.isFirst;
        return !removePrevious || isFirst; 
      }
    );
  } 

  static Future<T> goToOutfitDetailsScreen<T extends Object>(BuildContext context, bool removePrevious, {int outfitId, bool loadOutfit = false}) {
    return Navigator.pushAndRemoveUntil(context, 
      MaterialPageRoute(
        builder: (ctx) => OutfitDetailsScreen(
          outfitId: outfitId,
          loadOutfit: loadOutfit,
        ),
        settings: RouteSettings(
          name: '/outfit'
        )
      ),
      (Route<dynamic> route) {
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

  static Future<T> goToUploadOutfitScreen<T extends Object>(BuildContext context) {
    return Navigator.push(context, MaterialPageRoute(
      builder: (context) => UploadOutfitScreen(),
      settings: RouteSettings(
        name: '/upload-outfit'
      )
    ));
  }

  static Future<T> goToCommentsScreen<T extends Object>(BuildContext context, {int outfitId, bool focusComment = false, bool loadOutfit = false}) {
    return Navigator.push(context, MaterialPageRoute(
      builder: (ctx) => CommentsScreen(
        focusComment: focusComment,
        outfitId: outfitId,
        loadOutfit: loadOutfit,
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
}