import 'package:flutter/material.dart';

class RatingBar extends StatefulWidget {
  final int value;
  final double size;
  final ValueChanged<int> onUpdateRating;

  RatingBar({this.value, this.size = 32, this.onUpdateRating});

  @override
  _RatingBarState createState() => _RatingBarState();
}

class _RatingBarState extends State<RatingBar> {
  List<int> values = [1,2,3,4,5];
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onVerticalDragStart: _onDragStart,
          onVerticalDragUpdate: _onDragUpdate,
          child: Row(
            children: values.map((i) => _ratingIcon(i)).toList(),
          ),
        ),
      ],
    );
  }

  _onDragStart(DragStartDetails dragDetails) => _updateDragPos(dragDetails.globalPosition);
  _onDragUpdate(DragUpdateDetails dragDetails) => _updateDragPos(dragDetails.globalPosition);
  
  _updateDragPos(Offset globalPosition) {
    var localTouchPosition = (context.findRenderObject() as RenderBox).globalToLocal(globalPosition);
    bool isInXBounds = localTouchPosition.dx > 0 && localTouchPosition.dx <= widget.size*5;
    bool isInYBounds = localTouchPosition.dy > 0 && localTouchPosition.dy <= widget.size;
    if(isInXBounds && isInYBounds){
      int valueSelected = (localTouchPosition.dx / widget.size).ceil();
      widget.onUpdateRating(valueSelected);
    }
  }

  Widget _ratingIcon(int ratingThreshold){
    bool showRating = widget.value != null && ratingThreshold<= widget.value;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: showRating ? _fireIcon() : _emptyIcon(),
    );
  }
  Widget _fireIcon(){
    return Image.asset(
      'assets/flame.png',
    );
  }
  Widget _emptyIcon(){
    return Image.asset(
      'assets/empty-flame.png',
    );
  }
  
}