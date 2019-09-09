import 'package:flutter/material.dart';
import 'package:front_end/screens.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:helpers/helpers.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:front_end/providers.dart';
import 'package:blocs/blocs.dart';
import 'dart:async';
import 'dart:io';
import 'package:middleware/middleware.dart';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:overlay_support/src/notification/overlay_notification.dart';
import 'package:helpers/helpers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

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

  int numberOfPages = 4;
  
  List<String> pages = AppConfig.MAIN_PAGES;
  bool useSecondaryAdmobId = RemoteConfigHelpers.defaults[RemoteConfigHelpers.USE_SECONDARY_ADMOB_ID_KEY];

  @override
  void initState() {
    super.initState();
    _loadDefaultPageIndex();
    _loadSubscriptionStatus();
    SystemChannels.lifecycle.setMessageHandler((msg){
      if(msg==AppLifecycleState.resumed.toString()) {
        _loadNewNotifications();
        return null;
      }
    });
    _loadRemoteConfig();
  }

  _loadRemoteConfig() async {
    await RemoteConfigHelpers.fetchValues();
    RemoteConfig.instance.then((remoteConfig) {      
      bool newUseSecondaryAdmobId = remoteConfig.getBool(RemoteConfigHelpers.USE_SECONDARY_ADMOB_ID_KEY);
      if(useSecondaryAdmobId != newUseSecondaryAdmobId){
        _preferences.updatePreference(Preferences.USE_SECONDARY_ADMOB_ID, newUseSecondaryAdmobId);
        useSecondaryAdmobId = newUseSecondaryAdmobId;
      }
    });
  }

  _loadDefaultPageIndex() async {
    int newIndex = pages.indexOf(await _preferences.getPreference(Preferences.DEFAULT_START_PAGE));
    if(newIndex == -1){
      newIndex = numberOfPages-1;
    }
    setState(() {
     currentIndex = newIndex; 
    });
  }

  _loadSubscriptionStatus() async {
    useSecondaryAdmobId = await _preferences.getPreference(Preferences.USE_SECONDARY_ADMOB_ID);
    bool newHasSubscription = await _preferences.getPreference(Preferences.HAS_SUBSCRIPTION_ACTIVE);
    setState(() {
      hasSubscription = newHasSubscription;
    });
    if(hasSubscription){
      await _verifySubscriptionIsStillActive();
    }
    if(!hasSubscription){
      myInterstitial = createInterstitialAd();
    }
  }
  
  _verifySubscriptionIsStillActive() async {
    try{
      bool newHasSubscription = await FlutterInappPurchase.checkSubscribed(sku: AdmobTools.subscriptionId.first);
      setState(() {
        hasSubscription = newHasSubscription;
      });
    } on PlatformException {}
  }

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      adUnitId: AdmobTools.adUnitId,
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
        try{
          await myInterstitial.load();
        } on PlatformException {
          myInterstitial = createInterstitialAd();
        }
      }
      myInterstitial.show();
    }
  }

  _checkNotificationsPermission() async {
    try{
      await PermissionsChecker.checkNotificationsPermission();
    } on PlatformException {
      PermissionDialog.launch(context, permissionType: PermissionType.NOTIFICATIONS);
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
      body: _buildNotificationsScaffold(
        body: _buildMenuScaffold(
          body: IndexedStack(
            index: currentIndex,
            sizing: StackFit.expand,
            children: <Widget>[
              ExploreScreen(
                onShowAd: _showAd,
                hasSubscription: hasSubscription,
                onUpdateSubscriptionStatus: _onUpdateSubscriptionStatus,
              ),
              FeedScreen(
                onScrollChange: _onScrollChange,
              ),
              WardrobeScreen(
                onScrollChange: _onScrollChange,
              ),
              LookbooksScreen(
                hasSubscription: hasSubscription,
                onUpdateSubscriptionStatus: _onUpdateSubscriptionStatus,
                onScrollChange: _onScrollChange,
              ),
            ],
          )
        )
      ),
    );
  }

  _onScrollChange(ScrollController controller){
    bool isAtStart = controller.offset == 0.0;
    bool isScrollingDown = controller.position.userScrollDirection != ScrollDirection.forward;
    
    _isScrollingDown(isScrollingDown && !isAtStart);
  }

  _isScrollingDown(bool newIsScrollingDown){
    if(newIsScrollingDown != hideBars){
      setState(() {
       hideBars = newIsScrollingDown; 
      });
    }
  }

  _initBlocs() async {
    if(_userBloc == null){
      _logCurrentScreen();
      _userBloc = UserBlocProvider.of(context);
      _outfitBloc =OutfitBlocProvider.of(context);
      _notificationBloc = NotificationBlocProvider.of(context);
      _commentBloc =CommentBlocProvider.of(context);
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
      _registerNotificationToken();
      _notificationBloc.loadStaticNotifications.add(LoadNotifications(
        userId: userId
      ));
      String token = await widget.messaging.getToken();
      _notificationBloc.updateNotificationToken.add(UpdateToken(
        userId: userId,
        token: token,
      ));
      widget.messaging.configure(
        onMessage: (payload) async => _handleNotification(payload),
      );
      _checkNotificationsPermission();
    }
  }

  _registerNotificationToken() async { 
    String notificationToken = await widget.messaging.getToken();
    return _notificationBloc.updateNotificationToken.add(UpdateToken(
      userId: userId,
      token: notificationToken,
    ));
  }

  _logCurrentScreen() => AnalyticsEvents(context).logCustomScreen('/${AppConfig.MAIN_PAGES_PATHS[currentIndex]}');

  dynamic _handleNotification(Map<String, dynamic> payload) {
    dynamic dataMessageType;
    if(Platform.isAndroid){
      dataMessageType = payload['data'];
      if(dataMessageType != null){
        dataMessageType = dataMessageType['type'];
      }
    } else {
      dataMessageType = payload['type'];
    }
    bool isDataMessage = dataMessageType != null && !dataMessageType.isEmpty;
    if(isDataMessage){
      if(dataMessageType == "new-device"){
        _userBloc.logOut.add(null);
      }
    }else{
      _loadNewNotifications();
    }
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
      offset: 0.6,
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
        StreamBuilder<bool>(
          stream: _userBloc.currentUser.map((user) => user.hasNewFeedOutfits),
          initialData: false,
          builder: (context, hasFeedSnap) =>
            StreamBuilder<bool>(
              stream: _userBloc.currentUser.map((user) => user.hasNewUpload),
              initialData: false,
              builder: (context, hasNewUploadSnap) {
                bool hasNewFeed = hasFeedSnap.data == true;
                bool hasNewUpload = hasNewUploadSnap.data == true;
                return CustomScaffold(
                  resizeToAvoidBottomPadding: false,
                  backgroundColor: Colors.white,
                  leading: _buildMenuButton(),
                  title: 'FireFit',//pages[currentIndex],
                  customTitle: _customTitle(),
                  allCaps: false,
                  actions: <Widget>[
                    _buildUploadButton(),
                    _buildNotificationsButton(),
                  ],
                  elevation: 2.0,
                  appbarColor: Colors.grey[200],
                  body: body,
                  bottomNavigationBar: _buildBottomNavBar(hasNewFeed, hasNewUpload),
                );
              }
            ),
        ),
        _buildShading(),
      ],
    );
  }
  Widget _customTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'assets/flame_full.png',
          width: 24,
          height: 24,
        ),
        Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: Text(
            'FireFit',
            style: TextStyle(
              inherit: true,
              fontSize: 20,
              color: Colors.deepOrange[600]
            ),
          ),
        )
      ],
    );
  }

  bool hideBars = false;
  Widget _buildBottomNavBar(bool hasNewFeed, bool hasNewUpload) {
    return AnimatedContainer(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 1,
            color: Colors.black38,
            offset: Offset(0, 0)
          )
        ]
      ),
      duration: Duration(milliseconds: 100),
      height: hideBars ? 0 : 52+MediaQuery.of(context).padding.bottom,
      child: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: currentIndex,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[700],
        unselectedLabelStyle: Theme.of(context).textTheme.caption.copyWith(color: Colors.black),
        selectedLabelStyle: Theme.of(context).textTheme.caption.copyWith(color: Colors.blue),
        type: BottomNavigationBarType.fixed,
        onTap: _updatePageIndex,
        backgroundColor: Colors.grey[200],
        elevation: 6,
        items: [
          _buildBottomNavBarItem(
            icon: FontAwesomeIcons.globeAmericas,
            title: 'Inspiration',
          ),
          _buildBottomNavBarItem(
            icon: FontAwesomeIcons.users,
            title: 'Fashion Circle',
            showNotificationBubble: hasNewFeed,
          ),
          _buildBottomNavBarItem(
            icon: FontAwesomeIcons.personBooth,
            title: 'My Wardrobe',
            showNotificationBubble: hasNewUpload,
          ),
          _buildBottomNavBarItem(
            icon: FontAwesomeIcons.bookReader,
            title: 'Lookbooks',
          ),
        ]
      )
    );
  }

  _updatePageIndex(int newIndex) {
    if(newIndex == 1) {
      _userBloc.clearNewFeed.add(null);
    }else if(newIndex == 2) {
      _userBloc.markWardrobeSeen.add(null);
    }
    setState(() => currentIndex = newIndex);
  }

  BottomNavigationBarItem _buildBottomNavBarItem({IconData icon, String title, bool showNotificationBubble = false}){
    return BottomNavigationBarItem(
      backgroundColor: Colors.white,
      icon: Container(
        child: NotificationIcon(
          iconData: icon,
          size: 22.0,
          showBubble: showNotificationBubble,
        ),
      ),
     title: Padding(
      padding: EdgeInsets.only(top:4),
      child: Text(
          title,
          softWrap: true,
          style: TextStyle(
            inherit: true,
            fontSize: 12
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    return StreamBuilder<bool>(
      stream: _isSliderOpenController,
      initialData: false,
      builder: (context, isOpen) {
        return IconButton(
          icon: Icon(
            isOpen.data ? Icons.arrow_back : Icons.menu,
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
