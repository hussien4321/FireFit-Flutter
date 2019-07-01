import 'package:flutter/material.dart';
import 'package:middleware/middleware.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:helpers/helpers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OutfitStats extends StatelessWidget {

  final Outfit outfit;

  OutfitStats({this.outfit});

  @override
  Widget build(BuildContext context) {
    Style style = Style.fromStyleString(outfit.style);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        StyleSticker(
          style: style,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${outfit.commentsCount} ',
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                  Icon(
                    Icons.comment,
                    size: 16,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '${outfit.averageRating.round()} ',
                  style: Theme.of(context).textTheme.subtitle,
                ),
                Icon(
                  FontAwesomeIcons.fire,
                  size: 16,
                  color: Colors.black,
                ),
              ]
            ),
           ],
        ),
      ]
    );
  }
}