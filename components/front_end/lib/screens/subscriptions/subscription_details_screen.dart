import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:blocs/blocs.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:front_end/providers.dart';

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
  
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    hasSubscription = widget.hasSubscription;
    asyncInitState();
  }
  void asyncInitState() async {
    await FlutterInappPurchase.initConnection.then((res) => print('connection inited: $res'));
    isSubscribed = await _preferences.getPreference(Preferences.HAS_SUBSCRIPTION_ACTIVE);
    getItems();
  }
  void getItems () async {
    List<IAPItem> items = await FlutterInappPurchase.getSubscriptions(AdmobTools.subscriptionId);
    print('list of res :${items.length}');
    if(items.isNotEmpty){
      subscriptionItem = items.first;
      // isSubscribed
      _restorePurchases();
    }
  }

  @override
  void dispose() async{
    super.dispose();
    await FlutterInappPurchase.endConnection;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      resizeToAvoidBottomPadding: false,
      title: 'FireFit+',
      actions: <Widget>[
        FlatButton(
          child: Text("Restore"),
          onPressed: isLoading|| hasSubscription ? null : _restorePurchases,
        )
      ],
      body: _pageBody(),
    );
  }

  _restorePurchases() async {
    setState(() => isLoading = true);

    isSubscribed = await FlutterInappPurchase.checkSubscribed(sku: subscriptionItem.productId);
    print('isSubscribed:$isSubscribed');
    setState(() {
      isLoading=false;
    });
  }

  Widget _pageBody() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'For our biggest fans!',
              style: Theme.of(context).textTheme.headline,
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
      padding: EdgeInsets.only(left:16, right: 16, top: 16, bottom: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                hasSubscription ? 'Status': 'Monthly',
                style: Theme.of(context).textTheme.headline.copyWith(
                  fontWeight: FontWeight.w200
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      'isSubscribed: ${isSubscribed}',
                      style: Theme.of(context).textTheme.caption,
                      textAlign: TextAlign.center,
                    ),
                    errorMsg==null?Container() : Text(
                      errorMsg,
                      style: Theme.of(context).textTheme.caption.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Text(
                hasSubscription ? 'Active 🙌' : isLoading ? 'Loading...':'${subscriptionItem?.localizedPrice} (${subscriptionItem?.currency})',
                style: Theme.of(context).textTheme.headline.copyWith(
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
          //TODO: REMOVE THIS DETECTOR!
          GestureDetector(
            onTap: _unlockSubscription,
            child: RaisedButton(
              onPressed: hasSubscription || isLoading ? null : _unlockSubscription,
              color: Colors.blue,
              padding: EdgeInsets.all(16),
              child: Text(
                hasSubscription ? 
                'We appreciate your support! ❤️' :
                'Take my style to the next level!' ,
                style: Theme.of(context).textTheme.subhead.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w300
                ),
              ),
            ),
          )
        ]
      ),
    );
  }

  _unlockSubscription() async {
    if(hasSubscription){
      _switchSubscription(false);
    }
    try {
      print('buying purchase for ${subscriptionItem.productId}');
      PurchasedItem purchased= await FlutterInappPurchase.buySubscription(subscriptionItem.productId);
      print('purchased - ${purchased.toString()}');
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
}
