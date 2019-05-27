import 'package:flutter/material.dart';


abstract class ErrorDialog {

  void displayError(String message, BuildContext context){
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Container(
          padding: EdgeInsets.only(top:20.0, bottom: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Center(
                  child: Text(
                    'Error',
                    style: Theme.of(context).textTheme.title,
                  )
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "$message",
                  style: Theme.of(context).textTheme.button.apply(color: Theme.of(context).errorColor),
                  textAlign: TextAlign.center,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    child: Text('Close'),
                    onPressed: () => Navigator.pop(ctx),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void stopLoading(BuildContext context){
    Navigator.pop(context);
  }

}