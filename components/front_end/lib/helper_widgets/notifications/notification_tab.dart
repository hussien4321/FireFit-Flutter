import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:middleware/middleware.dart';

class NotificationTab extends StatefulWidget {

  final OutfitNotification notification;

  NotificationTab(this.notification);

  @override
  _NotificationTabState createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> {

  User get refUser => widget.notification.referencedUser;
  Outfit get refOutfit => widget.notification.referencedOutfit;
  
  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {},
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8.0),
          padding: EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            border: BorderDirectional(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.5)
              )
            )
          ),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 8.0),
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(refUser.profilePicUrl),
                    fit: BoxFit.cover
                  ),
                  color: Colors.grey
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              widget.notification.getNotificationTitle,
                              style: Theme.of(context).textTheme.subtitle,
                            )
                          ),
                          Text(
                            DateFormatter.dateToRecentFormat(widget.notification.createdAt),
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: refUser.name,
                              style: Theme.of(context).textTheme.subtitle
                            ),
                            TextSpan(
                              text: ' ${widget.notification.getNotificationDescription} ',
                              style: Theme.of(context).textTheme.body1
                            ),
                            TextSpan(
                              text: refOutfit.title,
                              style: Theme.of(context).textTheme.body2
                            ),
                          ]
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ),
      ),
    );
  }

}