import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:front_end/helper_widgets.dart';

class ProfilePicWithShadow extends StatelessWidget {
  
  final String url, userId;
  final double size;
  final EdgeInsets margin;
  final bool hasOnClick;
  final heroTag;
  final int pagesSinceOutfitScreen;
  final int pagesSinceProfileScreen;
  final bool isComingFromExploreScreen;
  
  ProfilePicWithShadow({
    this.url, 
    this.size = 40.0,
    this.margin = const EdgeInsets.only(right: 8.0),
    this.userId,
    this.hasOnClick = true,
    this.heroTag,
    this.pagesSinceOutfitScreen = 0,
    this.pagesSinceProfileScreen = 0,
    this.isComingFromExploreScreen = false,
  });
  
  @override
  Widget build(BuildContext context) {
    String hero = heroTag != null ? heroTag : 'PROFILE-PIC-URL-$url';
    return GestureDetector(
      onTap: hasOnClick ? () => _navigateToProfileScreen(context, hero) : null,
      child: Hero(
        tag: hero,
        child: Container(
          margin: margin,
          width: size,
          height: size,
          decoration: BoxDecoration(
            image: url == null ? null : DecorationImage(
              image: CachedNetworkImageProvider(url),
              fit: BoxFit.cover,
            ),
            shape: BoxShape.circle,
            color: Colors.grey,
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                offset: Offset(0, 2),
                blurRadius: 2,
                spreadRadius: 1
              )
            ]
          ),
        ),
      ),
    );
  }

  _navigateToProfileScreen(BuildContext context, String hero) {
    CustomNavigator.goToProfileScreen(context,
      userId: userId,
      heroTag: heroTag,
      pagesSinceOutfitScreen: pagesSinceOutfitScreen,
      pagesSinceProfileScreen: pagesSinceProfileScreen,
      isComingFromExploreScreen: isComingFromExploreScreen,
    );
  }
}