import 'package:flutter/material.dart';
import 'package:front_end/screens.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:helpers/helpers.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:front_end/providers.dart';
import 'package:blocs/blocs.dart';
import 'dart:async';
import 'package:middleware/middleware.dart';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:overlay_support/src/notification/overlay_notification.dart';
import 'package:helpers/helpers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:firebase_admob/firebase_admob.dart';

class MainAppBar extends StatefulWidget {

  final FirebaseMessaging messaging;

  MainAppBar({Key key,
    @required this.messaging,
  }) : super(key: key);

  @override
  _MainAppBarState createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar> {
  final GlobalKey<InnerDrawerState> _dmDrawerKey = GlobalKey<InnerDrawerState>();
  final GlobalKey<InnerDrawerState> _menuDrawerKey = GlobalKey<InnerDrawerState>();

  Preferences _preferences = Preferences();

  UserBloc _userBloc;
  OutfitBloc _outfitBloc;
  NotificationBloc _notificationBloc;
  CommentBloc _commentBloc;

  List<StreamSubscription<dynamic>> _subscriptions;

  OverlaySupportEntry _entry; 

  BehaviorSubject<bool> _isSliderOpenController =BehaviorSubject<bool>(seedValue: false);

  String userId;

  bool hasSubscription = false;

  InterstitialAd myInterstitial;

  int currentIndex = 0;

  List<Widget> get currentPages => [
    ExploreScreen(
      onShowAd: _showAd,
      hasSubscription: hasSubscription,
      onUpdateSubscriptionStatus: _onUpdateSubscriptionStatus,
    ),
    FeedScreen(),
    WardrobeScreen(),
    LookbooksScreen(
      hasSubscription: hasSubscription,
      onUpdateSubscriptionStatus: _onUpdateSubscriptionStatus,
    ),
  ];
  List<String> pages = AppConfig.MAIN_PAGES;

  @override
  void initState() {
    super.initState();
    _loadDefaultPageIndex();
    _loadSubscriptionStatus();
    SystemChannels.lifecycle.setMessageHandler((msg){
      if(msg==AppLifecycleState.resumed.toString()) {
        _dismissOpenNotifications();
        return null;
      }
    });
    RemoteConfigHelpers.fetchValues();
  }

  _loadDefaultPageIndex() async {
    int newIndex = pages.indexOf(await _preferences.getPreference(Preferences.DEFAULT_START_PAGE));
    if(newIndex == -1){
      newIndex = currentPages.length-1;
    }
    setState(() {
     currentIndex = newIndex; 
    });
  }

  _loadSubscriptionStatus() async {
    bool newHasSubscription = await _preferences.getPreference(Preferences.HAS_SUBSCRIPTION_ACTIVE);
    setState(() {
      hasSubscription = newHasSubscription;
    });
    if(!hasSubscription){
      myInterstitial = createInterstitialAd();
    }
  }

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      adUnitId: AdmobTools.testAdUnitId,
      targetingInfo: AdmobTools.targetingInfo,
      listener: (MobileAdEvent event) {
        if(event == MobileAdEvent.closed){
          myInterstitial = createInterstitialAd()..load();
        }
      },
    )..load();
  }


  _showAd() async {
    if(!hasSubscription){
      bool isLoaded = await myInterstitial.isLoaded();
      if(!isLoaded){
        await myInterstitial.load();
      }
      myInterstitial.show();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _subscriptions?.forEach((subscription) => subscription.cancel());
    _isSliderOpenController.close();
    myInterstitial?.dispose();
    myInterstitial = null;
  }


  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: SafeArea(
        child: _buildNotificationsScaffold(
          body: _buildMenuScaffold(
            body: currentPages[currentIndex]
          )
        ),
      ),
    );
  }

  _initBlocs() async {
    if(_userBloc == null){
      _logCurrentScreen();
      _userBloc = UserBlocProvider.of(context);
      _outfitBloc =OutfitBlocProvider.of(context);
      _notificationBloc = NotificationBlocProvider.of(context);
      _commentBloc =CommentBlocProvider.of(context);
      _dismissOpenNotifications();
      widget.messaging.configure(
        onMessage: (res) => _loadNewNotifications(),
      );
      _subscriptions = <StreamSubscription<dynamic>>[
        _tokenRefreshListener(),
        _logInStatusListener(),
        _showAdsListener(),
      ]..addAll(_successToastListeners())
      ..addAll(_uploadImagesListeners())
      ..addAll(_errorListeners());
      _userBloc.loadCurrentUser.add(null);
      _userBloc.refreshVerificationEmail.add(null);
      userId = await _userBloc.existingAuthId.first;
      _notificationBloc.registerNotificationToken.add(userId);
      _notificationBloc.loadStaticNotifications.add(LoadNotifications(
        userId: userId
      ));
    }
  }

  _logCurrentScreen() => AnalyticsEvents(context).logCustomScreen('/${AppConfig.MAIN_PAGES_PATHS[currentIndex]}');

  _dismissOpenNotifications(){
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.cancelAll();
  }

  _loadNewNotifications() {
    _notificationBloc.loadLiveNotifications.add(LoadNotifications(
      userId: userId
    ));
  }

  StreamSubscription _tokenRefreshListener() => widget.messaging.onTokenRefresh.listen((newToken) => _notificationBloc.updateNotificationToken.add(UpdateToken(
    userId: userId,
    token: newToken,
  )));
  
  StreamSubscription _showAdsListener() { 
    return _outfitBloc.showAd.listen((i) => _showAd());
  }

  StreamSubscription _logInStatusListener() { 
    return _userBloc.accountStatus.listen((accountStatus) {
      if(accountStatus!=null && accountStatus != UserAccountStatus.LOGGED_IN){
        if(accountStatus ==UserAccountStatus.LOGGED_OUT){
          AnalyticsEvents(context).logOut();
        }
        CustomNavigator.goToPageAtRoot(context, RouteConverters.getFromAccountStatus(accountStatus));
      }
    });
  }

  
  List<StreamSubscription> _errorListeners() => [ 
    _userBloc.hasError.listen((message) => _errorDialog(message)),
    _outfitBloc.hasError.listen((message) => _errorDialog(message)),
  ];

  _errorDialog(String message){
    ErrorDialog.launch(
      context,
      message: message,
    );
  }

  List<StreamSubscription> _successToastListeners() => [
    _userBloc.successMessage.listen((message) => toast(message)),
    _outfitBloc.successMessage.listen((message) => toast(message)),
    _notificationBloc.successMessage.listen((message) => toast(message)),
    _commentBloc.successMessage.listen((message) => toast(message)),
  ];

  List<StreamSubscription> _uploadImagesListeners() => [
    _outfitBloc.isBackgroundLoading.listen((isLoading) {
      if(isLoading){
        _entry = _backgroundLoadingOverlay('Uploading Outfit');
      }else{
        _closeOverlay();
      }
    }),
    _userBloc.isBackgroundLoading.listen((isLoading) {
      if(isLoading){
        _entry = _backgroundLoadingOverlay('Updating Profile');
      }else{
        _closeOverlay();
      }
    }),
  ];
  

  Widget _buildNotificationsScaffold({Widget body}) {
    return InnerDrawer(
      key: _dmDrawerKey,
      position: InnerDrawerPosition.end,
      onTapClose: true,
      swipe: false,
      offset: 0.7,
      animationType: InnerDrawerAnimation.linear,
      child: NotificationsScreen(),
      innerDrawerCallback: _updateMainScreenDimming,
      scaffold: body
    );
  }

  Widget _buildMenuScaffold({Widget body}){
    return InnerDrawer(
      key: _menuDrawerKey,
      position: InnerDrawerPosition.start,
      onTapClose: true,
      swipe: false,
      offset: 0.7,
      animationType: InnerDrawerAnimation.linear,
      child: MenuNavigationScreen(
        index: currentIndex,
        onPageSelected: (newIndex) {
          if(currentIndex != newIndex){
            currentIndex = newIndex;
            _logCurrentScreen();
          }
        },
        hasSubscription: hasSubscription,
        onUpdateSubscriptionStatus: _onUpdateSubscriptionStatus,
      ),
      innerDrawerCallback: _updateMainScreenDimming,
      scaffold: _buildScaffold(
        body: body
      )
    );
  }

  _onUpdateSubscriptionStatus(bool newSubscriptionStatus) => hasSubscription = newSubscriptionStatus;

  _updateMainScreenDimming(bool isOpen){
    setState(() {
      _isSliderOpenController.add(isOpen);
    });
  }

  Widget _buildScaffold({Widget body}){
    return Stack(
      children: <Widget>[
        CustomScaffold(
          resizeToAvoidBottomPadding: false,
          backgroundColor: Colors.white,
          leading: _buildMenuButton(),
          title: pages[currentIndex],
          allCaps: true,
          actions: <Widget>[
            _buildUploadButton(),
            _buildNotificationsButton(),
          ],
          elevation: 0.0,
          appbarColor: Colors.transparent,
          body: body
        ),
        _buildShading(),
      ],
    );
  }

  Widget _buildMenuButton() {
    return StreamBuilder<bool>(
      stream: _userBloc.currentUser.map((user) => user.hasNewFeedOutfits || user.hasNewUpload),
      initialData: false,
      builder: (context, hasDataSnap) {
        return IconButton(
          icon: NotificationIcon(
              iconData: Icons.menu,
              showBubble: hasDataSnap.data == true,
            ),
          onPressed: () => _menuDrawerKey.currentState.open(),
        );
      }
    );
  }

  Widget _buildUploadButton(){
    return IconButton(
      icon: Hero(
        tag: MMKeys.uploadButtonHero,
        child: Icon(Icons.add_a_photo),
      ),
      onPressed: () {
        if(!_userBloc.isEmailVerified.value){
          _requestEmailVerification();
        } else {
          CustomNavigator.goToUploadOutfitScreen(context,
            hasSubscription: hasSubscription,
            onUpdateSubscriptionStatus: _onUpdateSubscriptionStatus,
            isOnWardrobePage: currentIndex == 2,
          );
        }
      }
    );
  }

  _backgroundLoadingOverlay(String message) {
    return showSimpleNotification(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '$message...',
            style: Theme.of(context).textTheme.title.copyWith(
              color: Colors.blue,
              fontWeight: FontWeight.w300
            ),
          ),
          Theme(
            data: ThemeData(
              accentColor: Colors.blue
            ),
            child: CircularProgressIndicator(),
          )
        ],
      ),
      background: Colors.white,
      autoDismiss: false,
    );
  }
  _closeOverlay() => _entry?.dismiss(animate: true);

  _requestEmailVerification() async {
    _userBloc.refreshVerificationEmail.add(null);
    String email = await _userBloc.verificationEmail.first;
    await VerificationDialog.launch(context,
      actionName: 'upload an outfit',
      emailAddress: email
    );
    _userBloc.refreshVerificationEmail.add(null);
  }

  Widget _buildNotificationsButton() {
    return Center(
      child: StreamBuilder<int>(
        stream: _userBloc.currentUser.map((user) => user.numberOfNewNotifications),
        initialData: 0,
        builder: (ctx, countSnap) { 
          int messages = 0;
          if(countSnap.data != null){
            messages =countSnap.data;
          }
          return IconButton( 
            icon: NotificationIcon(
              iconData: Icons.notifications,
              messages: messages,
            ),
            onPressed: () => _dmDrawerKey.currentState.open()
          );
        }
      )  
    );
  }

  Widget _buildShading(){
    return StreamBuilder<bool>(
      stream: _isSliderOpenController,
      initialData: false,
      builder: (ctx, snap) {
        return Container(
          color: snap.data ? Colors.black.withOpacity(0.5) : null
        );
      }
    );
  }

}