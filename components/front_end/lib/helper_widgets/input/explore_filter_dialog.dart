import 'package:flutter/material.dart';

class ExploreFilterDialog extends StatefulWidget {

  
  @override
  _ExploreFilterDialogState createState() => _ExploreFilterDialogState();
}

class _ExploreFilterDialogState extends State<ExploreFilterDialog> {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      title: Text(
        'Rate this Fit',
        style: Theme.of(context).textTheme.display1.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'Cancel',
            style: Theme.of(context).textTheme.subtitle.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.bold
            ),
          ),
          onPressed: Navigator.of(context).pop,
        ),
        FlatButton(
          child: Text(
            'Update',
            style: Theme.of(context).textTheme.subtitle.copyWith(
              color: Colors.deepOrangeAccent,
              fontWeight: FontWeight.bold
            ),
          ),
          onPressed: _submitRating,
        )
      ],
     content: Column(
       crossAxisAlignment: CrossAxisAlignment.center,
       mainAxisSize: MainAxisSize.min,
       children: <Widget>[
         Padding(
           padding: const EdgeInsets.only(bottom: 16.0),
           child: _rateTranslation(),
         ),
       ],
     ),
    );
  }

  _submitRating() {
    Navigator.pop(context);
  }

  Widget _rateTranslation() {
    return Text(
      'Looking dope!',
      style: Theme.of(context).textTheme.title.copyWith(
        color: Colors.deepOrangeAccent,
        fontWeight: FontWeight.bold
      ),
    );
  }
}