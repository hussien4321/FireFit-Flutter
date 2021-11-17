import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ItemNotFound extends StatelessWidget {
  final String itemType;

  ItemNotFound({
    @required this.itemType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(
                    FontAwesomeIcons.exclamationTriangle,
                    size: 48,
                    color: Colors.red,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    '$itemType not found',
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(color: Colors.red),
                  ),
                ),
                Text(
                  "This may be due to the $itemType being deleted.",
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Colors.grey,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
