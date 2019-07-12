import 'package:flutter/material.dart';
import 'package:middleware/middleware.dart';
import 'package:front_end/helper_widgets.dart';

class UserPreviewCard extends StatelessWidget {

  final User user;
  final bool isPoster;
  final bool removePrevious;

  UserPreviewCard(this.user, {this.isPoster = false, this.removePrevious = false});

  @override
  Widget build(BuildContext context) {
    String hero = 'Outfit-details-poster-${user.profilePicUrl}';
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 3,
        color: Colors.grey[200],
        child: InkWell(
          onTap: () => _navigateToProfileScreen(context, hero),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ProfilePicWithShadow(
                  hasOnClick: false,
                  userId: user.userId,
                  url: user.profilePicUrl,
                  size: 50.0,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      isPoster ? Text(
                        'Posted by:',
                        style: Theme.of(context).textTheme.caption,
                      ) : Container(),
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.title,
                      ),
                      isPoster ? Container() : Text(
                        '@${user.username}',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'View Profile',
                    style: Theme.of(context).textTheme.button.apply(color: Colors.black),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _navigateToProfileScreen(BuildContext context, String hero) {
    CustomNavigator.goToProfileScreen(context, removePrevious,
      userId: user.userId,
      heroTag: hero,
    );
  }

}