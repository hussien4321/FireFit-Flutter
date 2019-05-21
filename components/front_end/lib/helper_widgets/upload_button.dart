import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';

class UploadButton extends StatelessWidget {
  final bool canBeUploaded;
  final VoidCallback onComplete;
  final VoidCallback onError;

  UploadButton({
    this.canBeUploaded,
    this.onComplete,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.send),
      color: canBeUploaded ? Colors.green : Colors.orange,
      onPressed: () {
        if(canBeUploaded){
          onComplete();
        }else{
          onError();
        }
      },
    );
  }
  
  _notifyIncompleteStatus(BuildContext context){
    Scaffold.of(context).removeCurrentSnackBar();
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: Text("Finish steps 1-3 first"),
    ));
  }
}