import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:middleware/middleware.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:helpers/helpers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/gestures.dart';

class FeedOutfits extends StatefulWidget {

  final bool isLoading;
  final List<Outfit> outfits;
  final bool hideTitle;
  final RefreshCallback onRefresh;
  final ValueChanged<Outfit> onReachEnd;

  FeedOutfits({this.outfits, this.isLoading, this.hideTitle = false, this.onRefresh, this.onReachEnd});

  @override
  _FeedOutfitsState createState() => _FeedOutfitsState();
}

class _FeedOutfitsState extends State<FeedOutfits> {


  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }
  _scrollListener() {
    if (_controller.offset >= (_controller.position.maxScrollExtent - 150) && !_controller.position.outOfRange) {
      if(widget.onReachEnd!=null && widget.outfits.isNotEmpty){
        widget.onReachEnd(widget.outfits.last);
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
      color: Colors.grey[300],
      width: double.infinity,
      child: _buildScrollableGrid(context)
    );
  }

  Widget _buildScrollableGrid(BuildContext ctx) {
    return PullToRefreshOverlay(
      matchSize: false,
      onRefresh: widget.onRefresh, 
      child: ListView.builder(
        controller: _controller,
        itemCount: widget.outfits.length+1,
        itemBuilder: (ctx,i) => i==widget.outfits.length ? _endOfListNotice(ctx) : _buildOutfitCard(i, widget.outfits[i], ctx, i==0),
      ),
    );
  }

  Widget _endOfListNotice(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 24),
      child: Center(
        child: widget.isLoading ? _loadingItemsMessage(ctx) :_noMoreItemsMessage(ctx),
      ),
    );
  }

  Widget _noMoreItemsMessage(BuildContext ctx) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'No ${moreTag}outfits to display\n',
            style: Theme.of(ctx).textTheme.subtitle.copyWith(
            ),
          ),
          TextSpan(
            text: 'Follow more users widen your fashion circle!',
            style: Theme.of(ctx).textTheme.caption.copyWith(
              color: Colors.black54
            ),
          ),
          TextSpan(
            text: "\n\nTap to Refresh",
            style: Theme.of(context).textTheme.subtitle.copyWith(
              decoration: TextDecoration.underline,
              color: Colors.blue,
            ),
            recognizer: TapGestureRecognizer()..onTap = () => widget.onRefresh(),
          )
        ]
      ),
      textAlign: TextAlign.center,      
    );
  }

  String get moreTag => widget.outfits.isEmpty ? '' : 'more ';

  Widget _loadingItemsMessage(BuildContext ctx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: CircularProgressIndicator(),
        ),
        Text(
          'Loading ${moreTag}outfits',
          style: Theme.of(ctx).textTheme.subhead.copyWith(
            color: Colors.black54
          ),
        )
      ],
    );
  }

  Widget _buildOutfitCard(int index, Outfit outfit, BuildContext ctx, bool isFirst) {
    return Container(
      margin: EdgeInsets.only(top: isFirst ? 16 : 0 , bottom: 16.0, left: 32, right: 32),
      child: GestureDetector(
        onTap: () => _openDetailedOutfit(outfit, ctx),
        child: Card(
          elevation: 2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
            ),
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _postBasicData(index, outfit, ctx),
                _outfitFullImageCard(outfit, ctx),
                // _outfitActions(outfit),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _openDetailedOutfit(Outfit outfit, BuildContext ctx){
    CustomNavigator.goToOutfitDetailsScreen(ctx, 
      outfitId: outfit.outfitId
    );
  }

  Widget _postBasicData(int index, Outfit outfit, BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: <Widget>[
          ProfilePicWithShadow(
            userId: outfit.poster.userId,
            heroTag: 'PROFILE-PIC-URL-${outfit.poster.profilePicUrl}-$index',
            url: outfit.poster.profilePicUrl,
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: outfit.poster.name,
                    style: Theme.of(context).textTheme.subtitle
                  ),
                  TextSpan(
                    text: '\nUploaded an outfit',
                    style: Theme.of(context).textTheme.caption
                  ),
                ]
              ),
            ),
          ),
          Text(
            DateFormatter.dateToSimpleFormat(outfit.poster.createdAt),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      ),
    );
  }

  Widget _outfitFullImageCard(Outfit outfit, BuildContext context) {
    return Container(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: 2/3,
        child: OutfitMainCard(outfit: outfit,)
      ),
    );
  }

  Widget _outfitStats(Outfit outfit, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              outfit.title,
              style: Theme.of(context).textTheme.title,
            ),
          ),
          OutfitStats(
            outfit: outfit,
          ),
        ]
      )
    );
  }
}