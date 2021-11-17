import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class DropdownButtons extends StatefulWidget {
  final List<DropdownOption> options;
  final Widget child;
  final bool alignStart, enabled;
  final ValueChanged<bool> onFocusChanged;
  
  DropdownButtons({
    @required this.child,
    @required this.options,
    @required this.alignStart,
    this.enabled = true,
    this.onFocusChanged,
  });

  @override
  _DropdownButtonsState createState() => _DropdownButtonsState();
}

class _DropdownButtonsState extends State<DropdownButtons> {
  
  bool areOptionsShown = false;
  
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(_listOfButtons());
    if(areOptionsShown){
      children.insert( widget.alignStart ? 1 : 0, _dropdownOptionsTags());
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _listOfButtons(){
    List<Widget> optionWidgets = [];
    if(areOptionsShown){
      optionWidgets.addAll(widget.options.map((option) {
        return _dropDownButton(
          child: option.child,
          onPressed: () {
            option.onPressed();
            _updateOptionsVisibility(false);
          }
        );
      }));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _dropDownButton(
          child: areOptionsShown ? Icon(Icons.keyboard_arrow_up, color: Colors.white) : widget.child,
          onPressed: widget.enabled ? () => _updateOptionsVisibility(!areOptionsShown) : null
        ),
      ]..addAll(optionWidgets),
    );
  }

  _updateOptionsVisibility(bool isOptionsShown){
    setState(() {
      areOptionsShown = isOptionsShown;
    });
    widget.onFocusChanged(isOptionsShown);
  }

  Widget _dropDownButton({Widget child, VoidCallback onPressed}){
    return RawMaterialButton(
      onPressed: onPressed,
      constraints: BoxConstraints(minWidth: 36.0, minHeight: 36.0),
      fillColor: Colors.black45,
      child: child,
      shape: CircleBorder(),
    );
  }

  Widget _dropdownOptionsTags(){
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.alignStart ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: <Widget>[
        Container(height: 48.0,),
      ]..addAll(widget.options.map((option) {
          return Container(
            height: 48.0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.black45
                ),
                child: Text(
                  option.tag,
                  style: Theme.of(context).textTheme.bodyText2.apply(color: Colors.white),
                ),
              )
            ),
          );
        })
      ),
    );
  }
}


class DropdownOption {
  Widget child;
  VoidCallback onPressed;
  String tag;

  DropdownOption({
    this.child,
    this.onPressed,
    this.tag,
  });
}