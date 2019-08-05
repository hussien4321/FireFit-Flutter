import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';

class LimitedFeatureSticker extends StatelessWidget {

  final String title, message;
  final bool isFull;
  final bool hasSubscription;
  final MainAxisAlignment mainAxisAlignment;
  final String benefit;
  final int initialPage;
  final ValueChanged<bool> onUpdateSubscriptionStatus;

  LimitedFeatureSticker({
    this.title,
    this.message,
    this.isFull,
    this.hasSubscription,
    this.benefit,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.initialPage = 0,
    this.onUpdateSubscriptionStatus,
  }); 

  @override
  Widget build(BuildContext context) {
    return hasSubscription ? _unlimitedSticker(context): _limitSticker(context);
  }

  Widget _unlimitedSticker(BuildContext context){
    return Text(
      'Unlimited',
      style: Theme.of(context).textTheme.subhead.copyWith(
        color: Color.fromRGBO(225, 173, 0, 1.0),
        fontWeight: FontWeight.bold
      ),
    );
  }

  Widget _limitSticker(BuildContext context) {
    return InkWell(
      onTap: () => SubscriptionDialog.launch(context,
        title: title,
        benefit: benefit,
        initialPage: initialPage,
        onUpdateSubscriptionStatus: onUpdateSubscriptionStatus,
      ),
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Row(
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              message,
              style: Theme.of(context).textTheme.subhead.copyWith(
                color: isFull ? Colors.red : Colors.blue,
                fontWeight: isFull ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.only(left: 4.0),
              child: Image.asset(
                'assets/flame_gold_plus_4.png',
                width: 20,
                height: 20,
              ),
            ),
          ],
        )
      ),
    );
  }
}