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

  OutfitNotification lastNotification;
  ScrollController _controller;

  List<OutfitNotification> notifications = [];

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }
  _scrollListener() {
    if (_controller.offset >= (_controller.position.maxScrollExtent - 100) && !_controller.position.outOfRange && notifications.length > 10){
      _notificationBloc.loadStaticNotifications.add(LoadNotifications(
        userId: userId,
        startAfterNotification: lastNotification,
      ));
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
  
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
          style: Theme.of(context).textTheme.title.copyWith(
            fontWeight: FontWeight.w300,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.2,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.playlist_add_check),
            onPressed: _clearNotifications,
          )
        ],
        elevation: 0.0,
      ),
      body: Container(
        child: StreamBuilder<bool>(
          stream: _notificationBloc.isLoading,
          initialData: false,
          builder: (ctx, isLoadingSnap) => StreamBuilder<List<OutfitNotification>>(
            stream: _notificationBloc.notifications,
            initialData: [],
            builder: (ctx, snap) {
              notifications = snap.data;
              if(notifications.length>0){
                lastNotification =notifications.last;
              }
              return PullToRefreshOverlay(
                matchSize: false,
                onRefresh: () async {
                  _notificationBloc.loadStaticNotifications.add(LoadNotifications(
                    userId: userId
                  ));
                },
                child: ListView(
                  physics: ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  controller: _controller,
                  children: _buildNotifications(notifications)..add(
                    _buildEndTag(isLoadingSnap.data, notifications.isEmpty)
                  )
                ),
              );
            },
          ),
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
          noText: 'Cancel',
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
  
  Widget _buildEndTag(bool isLoading, bool isEmpty) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: isLoading? _loadingTag(isEmpty) : _noNotificationsTag(isEmpty)
    );
  }

  Widget _loadingTag(bool isEmpty) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: CircularProgressIndicator(),
        ),
        Text(
          'Loading ${isEmpty?'':'more '}notifications',
          style: Theme.of(context).textTheme.subtitle.copyWith(
            color: Colors.black54
          ),
        ),
      ],
    );
  }
  Widget _noNotificationsTag(bool isEmpty) {
    return Text(
      'No ${isEmpty?'':'more '}notifications',
      style: Theme.of(context).textTheme.subtitle.copyWith(
        color: Colors.black54
      ),
      textAlign: TextAlign.center,
    );
  }
}