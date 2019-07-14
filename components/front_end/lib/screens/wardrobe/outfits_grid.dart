import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:middleware/middleware.dart';
import 'package:front_end/helper_widgets.dart';

class OutfitsGrid extends StatefulWidget {

  final bool isLoading;
  final List<Outfit> outfits;
  final bool hasFixedHeight;
  final RefreshCallback onRefresh;
  final VoidCallback onReachEnd;
  final String emptyText;
  final OutfitOverlay customOverlay;

  OutfitsGrid({this.outfits, this.isLoading, this.onReachEnd, this.onRefresh, this.emptyText, this.customOverlay ,this.hasFixedHeight = false});

  @override
  _OutfitsGridState createState() => _OutfitsGridState();
}

typedef Widget OutfitOverlay(Outfit outfit);
class _OutfitsGridState extends State<OutfitsGrid> {

  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }
  _scrollListener() {
    if (_controller.offset >= (_controller.position.maxScrollExtent-100) && !_controller.position.outOfRange) {
      if(widget.onReachEnd != null){
        widget.onReachEnd();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      width: double.infinity,
      child: _buildScrollableGrid(context)
    );
  }

  Widget _buildScrollableGrid(BuildContext ctx) {
    bool hasRefresh = widget.onRefresh != null;
    Widget content = ListView(
      shrinkWrap: true,
      controller: _controller,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 4),
        ),
        widget.outfits.isEmpty ? Container() : _displayGrid(hasRefresh), 
        Container(
          padding: EdgeInsets.all(12.0),
          child: widget.isLoading ? _loadingMoreNotice() : (widget.outfits.isEmpty ? _endOfListNotice() : Container()),
        )
      ],
    );
    if(hasRefresh){
      return PullToRefreshOverlay(
        matchSize: false,
        onRefresh: widget.onRefresh,
        child: content
      );
    }
    return content;
  }

  _displayGrid(bool hasRefresh) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1/2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4
      ),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.outfits.length,
      itemBuilder: (ctx, i) => _buildSimpleOutfitView(widget.outfits[i%widget.outfits.length], ctx),
    );
  }

  Widget _buildSimpleOutfitView(Outfit outfit, BuildContext ctx) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black45,
          width: 0.5
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTap: () => _openDetailedOutfit(outfit, ctx),
          child: Stack(
            children: <Widget>[
              SizedBox.expand(
                child: Hero(
                  tag: outfit.images.first,  
                  child: CachedNetworkImage(
                    imageUrl: outfit.images[0],
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
              widget.customOverlay == null ? Container() : widget.customOverlay(outfit),
            ],
          ),
        ),
      ),
    );
  }

  _openDetailedOutfit(Outfit outfit, BuildContext ctx){
    CustomNavigator.goToOutfitDetailsScreen(ctx, true, 
      outfitId: outfit.outfitId
    );
  }

  Widget _loadingMoreNotice(){
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircularProgressIndicator(),
          ),
          Text(
            'Loading ${widget.outfits.isEmpty?'':'more '}fits...',
            style: Theme.of(context).textTheme.subtitle.copyWith(
              color: Colors.black54
            ),
          )
        ],
      ),
    );
  }

  Widget _endOfListNotice() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: Text(
          widget.emptyText,
          style: Theme.of(context).textTheme.subtitle.copyWith(
            color: Colors.black54
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}