import 'package:flutter/material.dart';
import 'package:middleware/middleware.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DemographicSticker extends StatelessWidget {

  final User user;

  DemographicSticker(this.user);

  @override
  Widget build(BuildContext context) {
    Color color = user.genderIsMale ? Colors.blue : Colors.pink;
    return Container(
      padding: EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            user.genderIsMale ? FontAwesomeIcons.male : FontAwesomeIcons.female,
            color: Colors.white,
            size: 16,
          ),
          Text(
            user.ageRange,
            style: Theme.of(context).textTheme.body2.apply(color: Colors.white),
          )
        ],
      ),
    );
  }
}