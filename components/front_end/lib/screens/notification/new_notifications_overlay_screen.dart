import 'package:flutter/material.dart';
import 'package:blocs/blocs.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:front_end/providers.dart';
import 'package:meta/meta.dart';
import 'dart:async';

class NewNotificationsOverlayScreen extends StatefulWidget {
  
  final FirebaseMessaging messaging;
  final Widget body;

  NewNotificationsOverlayScreen({
    @required this.messaging,
    @required this.body,
  });

  @override
  _NewNotificationsOverlayScreenState createState() => _NewNotificationsOverlayScreenState();
}

class _NewNotificationsOverlayScreenState extends State<NewNotificationsOverlayScreen> {
  
  NotificationBloc _notificationBloc;
  UserBloc _userBloc;
  List<StreamSubscription<dynamic>> _subscriptions;

  static double _MAX_HEIGHT = -150;
  double height = _MAX_HEIGHT;
  
  @override
  void dispose() {
    _subscriptions?.forEach((subscription) => subscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          widget.body,
          _buildOverheadTab(),
        ],
      ),
    );
  }

  _initBlocs(){
    if(_notificationBloc == null){
      _userBloc = UserBlocProvider.of(context);
      _notificationBloc = NotificationBlocProvider.of(context);
      widget.messaging.configure(
        onMessage: (res) => _loadNewNotifications(),
      );
      _subscriptions = <StreamSubscription<dynamic>>[];
    }
  }

  _loadNewNotifications() async {
    String userId = await _userBloc.existingAuthId.first;
    _notificationBloc.loadLiveNotifications.add(userId);
    _startNotificationAnimation();
  }

  _startNotificationAnimation() async {
    Future.delayed(Duration.zero, () => setState(() => height = 0));
    Future.delayed(Duration(seconds: 3), () => setState(() => height = _MAX_HEIGHT));
  }
  
  _endNotificationAnimation() async {
    Future.delayed(Duration.zero, () => setState(() => height = _MAX_HEIGHT));
  }
  Widget _buildOverheadTab(){
    return SafeArea(
      child: GestureDetector(
        onVerticalDragUpdate: (details)=> _endNotificationAnimation(),
        onTap: _endNotificationAnimation,
        child: AnimatedContainer(
          transform: Matrix4.translationValues(0, 0, 0),
          decoration: BoxDecoration(
            color: Colors.blueGrey[700],
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(12)
            )
          ),
          duration: Duration(milliseconds: 300),
          width: double.infinity,
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'New notification!',
                        style: Theme.of(context).textTheme.title.apply(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 100,
                  height: 2,
                  margin: EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}