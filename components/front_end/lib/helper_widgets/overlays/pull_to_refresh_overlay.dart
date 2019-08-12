import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class PullToRefreshOverlay extends StatefulWidget {
  
  final Widget child;
  final RefreshCallback onRefresh;
  final bool matchSize;
  
  PullToRefreshOverlay({
    @required this.child,
    @required this.onRefresh,
    this.matchSize = false,
  });

  @override
  _PullToRefreshOverlayState createState() => _PullToRefreshOverlayState();
}

class _PullToRefreshOverlayState extends State<PullToRefreshOverlay> {
 
  Duration _showSpinnerDuration = Duration(seconds: 1);
 
  GlobalKey containerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RefreshIndicator(
        onRefresh: _displayTempRefresh,
        child: widget.matchSize ? _staticBuild() : widget.child,
      )
    );
  }

  Future<void> _displayTempRefresh() async {
    await widget.onRefresh();
    await Future.delayed(_showSpinnerDuration);
  }

  Widget _staticBuild() {
    return LayoutBuilder(
      key: containerKey,
      builder: (ctx, constraints)=> Container(
        child:_matchingChildWidget(constraints)
      ),
    );
  }
  Widget _matchingChildWidget(BoxConstraints constraints) {
    final height = constraints.maxHeight;
    return ListView(
      physics: ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      children: [
        SizedBox(
          height: height,
          child: widget.child
        )
      ]
    );
  }
}