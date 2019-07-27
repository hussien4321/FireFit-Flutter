import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SubscriptionDetailsScreen extends StatefulWidget {
  @override
  _SubscriptionDetailsScreenState createState() => _SubscriptionDetailsScreenState();
}

class _SubscriptionDetailsScreenState extends State<SubscriptionDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'FireFit+',
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.restore),
          onPressed: null,
          tooltip: "Restore Purchases",
        )
      ],
      body: _pageBody(),
    );
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
            description: 'Have even more fun editing & creating lookbooks with no limits for number of outfits added.\n(Free version is 100 max)',
          ),
          BenefitOverview(
            icon: FontAwesomeIcons.bolt,
            title: '2 Boosts a month',
            description: "Boost your outfit to the front of the inspiration page for 6 hours so you can get extra feedback on experimental outfits!",
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
                'MONTHLY',
                style: Theme.of(context).textTheme.headline.copyWith(
                  fontWeight: FontWeight.w200
                ),
              ),
              Text(
                  '\$6.99 USD',
                  style: Theme.of(context).textTheme.headline.copyWith(
                  ),
                ),
            ],
          ),
          RaisedButton(
            onPressed: () {},
            color: Colors.blue,
            padding: EdgeInsets.all(16),
            child: Text(
              'Take my style to the next level!',
              style: Theme.of(context).textTheme.subhead.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w300
              ),
            ),
          )
        ]
      ),
    );
  }
}

class BenefitOverview extends StatelessWidget {

  final IconData icon;
  final String title, description;

  BenefitOverview({
    this.icon,
    this.title,
    this.description,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 2,
                  offset: Offset(0, 2)
                ),
              ]
            ),
            child: Icon(
              icon,
              size: 48,
              color: Colors.blue,
            )
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.title,
              textAlign: TextAlign.center,
            ),
          ),
          Flexible(
            child: Text(
              description,
              style: Theme.of(context).textTheme.subtitle.copyWith(
                color: Colors.grey
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ]
      ),
    );
  }
}