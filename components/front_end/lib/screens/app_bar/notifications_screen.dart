import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:blocs/blocs.dart';
import 'package:middleware/middleware.dart';
import 'package:front_end/providers.dart';
import 'package:front_end/helper_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  NotificationBloc _notificationBloc;
  UserBloc _userBloc;
  
  String userId;

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        leading: null,
        automaticallyImplyLeading: false,
        title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.title,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: _clearNotifications,
          )
        ],
        elevation: 0.0,
      ),
      body: Container(
        child: StreamBuilder<List<OutfitNotification>>(
          stream: _notificationBloc.notifications,
          initialData: [],
          builder: (ctx, snap) {
            return ListView(
              children: _buildNotifications(snap.data)..add(
                _buildMoreNotificationsButton()
              )
            );
          },
        ),
      ),
    );
  }
  _initBlocs() async {
    if(_notificationBloc == null){
      _notificationBloc =NotificationBlocProvider.of(context);
      _userBloc =UserBlocProvider.of(context);
      userId = await _userBloc.existingAuthId.first;
    }
  }

  _clearNotifications() {
    return showDialog(
      context: context,
      builder: (secondContext) {
          MarkNotificationsSeen markSeen = MarkNotificationsSeen(
            userId: userId,
          );
          return YesNoDialog(
          title: 'Mark as seen',
          description: 'Are you sure you want to mark all notifications as seen?',
          yesText: 'Yes',
          noText: 'No',
          onYes: () {
            _notificationBloc.markNotificationsSeen.add(markSeen);
            Navigator.pop(context);
          },
          onDone: () {
            Navigator.pop(context);
          },
        );
      }
    ) ?? false;
  }

  List<Widget> _buildNotifications(List<OutfitNotification> notifications){
    List<Widget> previews = [];
    for(int i = 0; i < notifications.length; i++){
      previews.add(NotificationTab(notifications[i]));
    }
    return previews;
  }
  
  Widget _buildMoreNotificationsButton() {
    return Container(
      width: double.infinity,
      child: FlatButton(
        padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text('Load previous'),
          onPressed: () {},
        ),
    );
  }
}