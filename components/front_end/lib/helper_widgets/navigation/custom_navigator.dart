import 'package:flutter/material.dart';
import 'package:front_end/screens.dart';

class CustomNavigator {

  //TODO: GET ROUTE STACK FROM OBSERVER TO DETERMINE IF IT NEEDS TO REWIND

  static goToProfileScreen(BuildContext context, bool removePrevious, {String userId, String heroTag}) {
    Navigator.pushAndRemoveUntil(context, 
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

  static goToOutfitDetailsScreen(BuildContext context, bool removePrevious, {int outfitId}) {
    Navigator.pushAndRemoveUntil(context, 
      MaterialPageRoute(
        builder: (ctx) => OutfitDetailsScreen(
          outfitId: outfitId,
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
}