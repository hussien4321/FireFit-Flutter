import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:meta/meta.dart';

class PullToRefreshOverlay extends StatefulWidget {
  
  final Widget child;
  final VoidCallback onRefresh;
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
 
  GlobalKey containerKey = GlobalKey();
  RefreshController _refreshController;
  initState(){
    super.initState();
    _refreshController = RefreshController(initialRefresh:false);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      key: containerKey,
      builder: (ctx, constraints)=> Container(
        height: double.infinity,
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header:  WaterDropMaterialHeader(
            backgroundColor: Colors.grey,
          ),
          controller: _refreshController,
          onRefresh: () async {
            widget.onRefresh();
            await Future.delayed(Duration(seconds:1));
            _refreshController.refreshCompleted();
          },
          child: widget.matchSize ? _matchingChildWidget(constraints) : widget.child
        ),
      ),
    );
  }

  Widget _matchingChildWidget(BoxConstraints constraints) {
    final height = constraints.maxHeight;
    return SizedBox(
      height: height,
      child: widget.child,
    );
  }
}