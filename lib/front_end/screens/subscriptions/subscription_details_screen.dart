import 'package:flutter/material.dart';
import '../../../../front_end/helper_widgets.dart';
import '../../../../blocs/blocs.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import '../../../../front_end/providers.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import '../../../../helpers/helpers.dart';
import 'package:flutter/gestures.dart';

class SubscriptionDetailsScreen extends StatefulWidget {

  final int initialPage;
  final bool hasSubscription;
  final ValueChanged<bool> onUpdateSubscriptionStatus;

  SubscriptionDetailsScreen({this.initialPage = 0, this.hasSubscription, this.onUpdateSubscriptionStatus});

  @override
  _SubscriptionDetailsScreenState createState() => _SubscriptionDetailsScreenState();
}

class _SubscriptionDetailsScreenState extends State<SubscriptionDetailsScreen> {

  Preferences _preferences = Preferences();
  bool hasSubscription;
  IAPItem subscriptionItem;
  bool isSubscribed = false;
  String errorMsg;
  List<PurchasedItem> purchases = [];
  
  bool hasConnection = true;
  bool isLoading = true;

  //TODO: Debug only value
  bool hideLogButton = true;

  bool get hasPreviousPurchase => purchases.length > 0;

  @override
  void initState() {
    super.initState();
    hasSubscription = widget.hasSubscription;
    asyncInitState();
  }
  void asyncInitState() async {
    try {
      await _checkConnection();
      await FlutterInappPurchase.instance.initConnection.then((res) => print('connection inited: $res'));
      isSubscribed = await _preferences.getPreference(Preferences.HAS_SUBSCRIPTION_ACTIVE);
      await _getItems();
    } on PlatformException {
      setState(() {
       hasConnection = false; 
      });
    }
    setState(() {
      isLoading=false;
    });
  }

  _checkConnection() async {
    bool isConnectedNow = await ConnectivityHelper.hasConnection();
    if(!isConnectedNow){
      throw PlatformException(
        code: 'NO CONNECTION!'
      );
    }
  }
  _getItems() async {
    List<IAPItem> items = await FlutterInappPurchase.instance.getSubscriptions(AdmobTools.subscriptionId);
    purchases = await FlutterInappPurchase.instance.getPurchaseHistory();
    if(items.isNotEmpty){
      subscriptionItem = items.first;
    }
  }

  @override
  void dispose() async{
    super.dispose();
    await FlutterInappPurchase.instance.endConnection;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      resizeToAvoidBottomPadding: false,
      title: 'FireFit+',
      actions: <Widget>[
        hideLogButton ? Container() :
        FlatButton(
          child: Text("Logs"),
          onPressed: isLoading || !hasConnection ? null : _showLogs,
        )
      ],
      body: _pageBody(),
    );
  }

  _showLogs() {
    String variablesLog = 'Found ${purchases?.length} Purchases!\n\n';
    variablesLog += 'isSubscribed: $isSubscribed\n\n';
    variablesLog += 'hasPreviousPurchase: $hasPreviousPurchase\n\n';
    String productLog = "";
    subscriptionItem.toString().split(',').forEach((entry) => productLog+='$entry\n\n');

    return CustomDialog.launch(context, 
      title: "Subscription Logs",
      content: Column(
        children: <Widget>[
          Text(
            variablesLog,
            style: Theme.of(context).textTheme.caption.copyWith(color: Colors.blue),
            textAlign: TextAlign.center,
          ),
          Text(
            productLog,
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.center,
          ),
          errorMsg==null?Container() : Text(
            errorMsg,
            style: Theme.of(context).textTheme.caption.copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
      ) 
    );
  }


  Widget _pageBody() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4, right: 4),
            child: Text(
              'Get unlimited access, no ads & more!',
              style: Theme.of(context).textTheme.overline,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: _benefitsOverview()
          ),
          Expanded(
            flex: 2,
            child: _paymentPrompt(),
          )
        ],
      ),
    );
  }

  Widget _benefitsOverview() {
    return Center(
      child: CarouselSliderWithIndicator(
        viewportFraction: 1.0,
        enableInfiniteScroll: false,
        initialPage: widget.initialPage,
        items: <Widget>[
          BenefitOverview(
            icon: FontAwesomeIcons.cameraRetro,
            title: 'Unlimited daily uploads',
            description: 'Go wild experimenting with new fits all day long with no limits!',
          ),
          BenefitOverview(
            icon: FontAwesomeIcons.ad,
            title: 'No ads',
            description: 'Spend as much time as you want browsing and interacting with outfits with no interruptions!',
          ),
          BenefitOverview(
            icon: FontAwesomeIcons.server,
            title: 'Unlimited lookbooks storage',
            description: 'Enjoy unlimited number of outfits across all your customized lookbooks for every style',
          ),
          BenefitOverview(
            icon: FontAwesomeIcons.globeEurope,
            title: 'Custom country search',
            description: 'See the different & unique fashion trends from any country in the world!',
          ),
          BenefitOverview(
            icon: FontAwesomeIcons.calendarAlt,
            title: 'Custom date range search',
            description: "Want to see the hottest fits from new year's day? Halloween? or even in the middle of the summer?\nSearch for the best outfits across any date range!",
          ),
        ],
      ),
    );
  }

  _paymentPrompt(){
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          isLoading || !hasConnection ? Container() :
          (hasSubscription ?
            _paidBanner() :
            _itemPrice()
          ),
          _buyButton(),
          _legalInfo(),
          _restoreButton(),
        ]
      ),
    );
  }

  Widget _paidBanner() {
    return Text(
      'Thanks for your support! ❤️',
      style: Theme.of(context).textTheme.headline5.copyWith(
        fontWeight: FontWeight.normal
      ),
    );
  }

  Widget _itemPrice() {
    List<TextSpan> priceContent=[];
    priceContent.add(
      TextSpan(
        text: '${subscriptionItem?.localizedPrice}',
        style: TextStyle(
          inherit: true,
          color: Colors.blue,
        )
      ),
    );
    priceContent.add(
      TextSpan(
        text: '/month${hasPreviousPurchase?'':'\n'}',
      )
    );
    if(!hasPreviousPurchase){
      priceContent.add(
        TextSpan(
            text: '${subscriptionItem?.introductoryPrice} for the 1st month!',
          style: TextStyle(
            inherit: true,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          )
        ),
      );
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: Theme.of(context).textTheme.headline5.copyWith(
          color: Colors.grey[700],
          fontSize: 20,
        ),
        children: priceContent
      ),
    );
  }

  Widget _buyButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      child: RaisedButton(
        onPressed: hasSubscription || isLoading || !hasConnection ? null : _unlockSubscription,
        color: Colors.blue,
        padding: EdgeInsets.all(16),
        child: Text(
          isLoading ? 'Connecting...' :
          !hasConnection ? 'No connection' :
          hasSubscription ? 
          'Subscription active' :
          'Subscribe now!' ,
          style: Theme.of(context).textTheme.headline5.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  _unlockSubscription() async {
    try {
      await FlutterInappPurchase.instance.requestPurchase(subscriptionItem.productId);
      _switchSubscription(true);
    } catch (error) {
      print('$error');
      setState(() {
        errorMsg = error.toString();      
      });
    }
  }
  _switchSubscription(bool isActive){
    setState(() {
      hasSubscription = isActive;
    });
    _preferences.updatePreference(Preferences.HAS_SUBSCRIPTION_ACTIVE, isActive);
    widget.onUpdateSubscriptionStatus(isActive);
  }

  Widget _legalInfo(){
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: Theme.of(context).textTheme.caption.copyWith(
          color: Colors.blue,
          decoration: TextDecoration.underline
        ),
        children: [
          TextSpan(
            text: 'Privacy policy',
            recognizer: TapGestureRecognizer()..onTap = () => UrlLauncher.openURL(AppConfig.PRIVACY_POLICY_URL),
          ),
          TextSpan(
            text: ' and ',
            style: TextStyle(
              inherit: true,
              color: Colors.black,
              decoration: TextDecoration.none
            )
          ),
          TextSpan(
            text: 'Terms & Conditions',
            recognizer: TapGestureRecognizer()..onTap = () => UrlLauncher.openURL(AppConfig.TERMS_AND_CONDITIONS_URL),
          ),
        ]
      ),
    );
  }

  Widget _restoreButton(){
    return FlatButton(
      child: Text("Restore purchases"),
      onPressed: isLoading || hasSubscription ?  null : _restorePurchases,
    );
  }

  _restorePurchases() async {
    setState(() => isLoading = true);
    isSubscribed = await FlutterInappPurchase.instance.checkSubscribed(sku: AdmobTools.subscriptionId.first);
    await Future.delayed(Duration(seconds: 2));
    _switchSubscription(isSubscribed);
    setState(() {
      isLoading=false;
    });
  }
}
