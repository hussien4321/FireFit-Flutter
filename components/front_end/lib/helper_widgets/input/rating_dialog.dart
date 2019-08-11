import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';

class RatingDialog extends StatefulWidget {

  final int initialValue;
  final bool isUpdate;
  final ValueChanged<int> onSubmit;

  RatingDialog({this.initialValue, this.isUpdate, this.onSubmit});

  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {

  int rating;

  @override
  void initState() {
    super.initState();
    rating = widget.initialValue;
  }
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
              color: Colors.black54,
              fontWeight: FontWeight.bold
            ),
          ),
          onPressed: Navigator.of(context).pop,
        ),
        RaisedButton(
          color: hasRating ? Colors.deepOrangeAccent : Colors.black54,
          child: Text(
            widget.isUpdate ? 'Update' : 'Submit',
            style: Theme.of(context).textTheme.subtitle.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          ),
          onPressed: hasRating ? _submitRating : null,
        )
      ],
    backgroundColor: Colors.white70,
     content: Column(
       crossAxisAlignment: CrossAxisAlignment.center,
       mainAxisSize: MainAxisSize.min,
       children: <Widget>[
         Padding(
           padding: const EdgeInsets.only(bottom: 16.0),
           child: _rateTranslation(),
         ),
         RatingBar(
          size: 36,
          value: rating?.toDouble(),
          onUpdateRating: (newRating) => setState(() => rating=newRating),
           ),
       ],
     ),
    );
  }
  bool get hasRating => rating != null && hasNewRating;
  bool get hasNewRating => !widget.isUpdate || (widget.isUpdate && widget.initialValue != rating);

  _submitRating() {
    widget.onSubmit(rating);
    Navigator.pop(context);
  }

  Widget _rateTranslation() {
    return Text(
      _rateText,
      style: Theme.of(context).textTheme.title.copyWith(
        color: rating != null ? Colors.deepOrangeAccent[700] : Colors.transparent,
        fontWeight: FontWeight.bold
      ),
    );
  }

  String get _rateText {
    switch (rating) {
      case 5:
        return "That's a Fire Fit!";
      case 4:
        return "Great";
      case 3:
        return "Alright";
      case 2:
        return "Not bad";
      case 1:
        return "Needs fixing up";
      default:
        return "TEST";
    }
  }
}