import 'package:flutter/material.dart';
import '../../../../helpers/helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../middleware/middleware.dart';
import '../../../../front_end/helper_widgets.dart';
import '../../../../blocs/blocs.dart';
import '../../../../front_end/providers.dart';
import '../../../../front_end/screens.dart';

class NotificationTab extends StatefulWidget {

  final OutfitNotification notification;

  NotificationTab(this.notification);

  @override
  _NotificationTabState createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> {

  NotificationBloc _notificationBloc;
  UserBloc _userBloc;

  String userId;

  User get refUser => widget.notification.referencedUser;
  Outfit get refOutfit => widget.notification.referencedOutfit;
  bool get hasRefOutfit => refOutfit != null;
  Comment get refComment => widget.notification.referencedComment;
  
  @override
  Widget build(BuildContext context) {
    initBlocs();
    return Material(
      color: widget.notification.isSeen ? Colors.white: Colors.grey[200],
      child: InkWell(
        onTap: _openNotification,
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
              GestureDetector(
                onTap: () => CustomNavigator.goToProfileScreen(context,
                  userId: refUser.userId,
                ),
                child: Container(
                  margin: EdgeInsets.only(right: 8.0),
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: refUser == null ? null : DecorationImage(
                      image: CachedNetworkImageProvider(refUser.profilePicUrl),
                      fit: BoxFit.cover
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 4,
                        spreadRadius: -2,
                        offset: Offset(0, 2)
                      )
                    ],
                    color: Colors.grey
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              widget.notification.getNotificationTitle,
                              style: Theme.of(context).textTheme.headline5.apply(fontWeightDelta: 3),
                            )
                          ),
                          Text(
                            DateFormatter.dateToRecentFormat(widget.notification.createdAt),
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                   TextSpan(
                                    text: refUser?.name,
                                    style: Theme.of(context).textTheme.subtitle1
                                  ),
                                  TextSpan(
                                    text: ' ${widget.notification.getNotificationDescription} ',
                                    style: Theme.of(context).textTheme.bodyText1
                                  ),
                                  TextSpan(
                                    text: isCommentNotification ? refComment?.text : refOutfit?.title,
                                    style: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.deepOrange)
                                  ),
                                ]
                              ),
                            ),
                          ),
                        ),
                        hasRefOutfit ? Container(
                          margin: EdgeInsets.only(right: 8.0),
                          width: 35.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(refOutfit.images.first),
                              fit: BoxFit.cover
                            ),
                            border: Border.all(
                              width: 0.5
                            ),
                            color: Colors.grey
                          ),
                        ) : Container(),
                      ],
                    ),
                  ],
                ),
              ),
              
            ],
          )
        ),
      ),
    );
  }

  initBlocs() async {
    if(_notificationBloc ==null){
      _notificationBloc =NotificationBlocProvider.of(context);
      _userBloc =UserBlocProvider.of(context);
      userId = await _userBloc.existingAuthId.first;
    }
  }

  _openNotification() {
    if(!widget.notification.isSeen) {
      MarkNotificationsSeen markSeen = MarkNotificationsSeen(
        userId: userId,
        notificationId: widget.notification.notificationId,
      );
      _notificationBloc.markNotificationsSeen.add(markSeen);
    }
    if(widget.notification.type == NotificationType.OUTFIT_RATING || widget.notification.type == NotificationType.NEW_OUTFIT){
      CustomNavigator.goToOutfitDetailsScreen(context, 
        outfitId: refOutfit.outfitId,
        loadOutfit: true
      );
    }
    if(isCommentNotification){
      CustomNavigator.goToCommentsScreen(
        context,
        outfitId: refOutfit.outfitId,
        loadOutfit: true,
      );
    }
    if(widget.notification.type == NotificationType.NEW_FOLLOW){
      CustomNavigator.goToProfileScreen(context,
        userId: refUser.userId,
      );
    }
  }

  bool get isCommentNotification => widget.notification.type == NotificationType.NEW_COMMENT || widget.notification.type == NotificationType.COMMENT_LIKE || widget.notification.type == NotificationType.COMMENT_REPLY || widget.notification.type == NotificationType.REPLY_THREAD;
}