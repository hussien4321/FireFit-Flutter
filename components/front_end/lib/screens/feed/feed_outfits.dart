import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:middleware/middleware.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:helpers/helpers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FeedOutfits extends StatelessWidget {

  final bool isLoading;
  final List<Outfit> outfits;
  final bool hideTitle;

  FeedOutfits({this.outfits, this.isLoading, this.hideTitle = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      width: double.infinity,
      child: outfits.isEmpty && !isLoading ? _buildNoOutfitsMessage() : _buildScrollableGrid(context)
    );
  }

  Widget _buildNoOutfitsMessage() {
    return CustomBanner(
      icon: FontAwesomeIcons.meh,
      text: "None of your followers have uploaded any outfits, go to the inspiration page to find new users to follow!",
    );
  }

  Widget _buildScrollableGrid(BuildContext ctx) {
    return ListView.builder(
      itemCount: outfits.length,
      itemBuilder: (ctx, i) => _buildOutfitCard(i, outfits[i], ctx),
    );
  }

  Widget _buildOutfitCard(int index, Outfit outfit, BuildContext ctx) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 32.0),
      child: GestureDetector(
        onTap: () => _openDetailedOutfit(outfit, ctx),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _postBasicData(index, outfit, ctx),
              _outfitFullImage(outfit, ctx),
              _outfitStats(outfit, ctx),
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

  Widget _postBasicData(int index, Outfit outfit, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
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
                    text: ' has uploaded a new outfit',
                    style: Theme.of(context).textTheme.caption
                  ),
                ]
              ),
            ),
          ),
          Text(
            DateFormatter.dateToRecentFormat(outfit.poster.createdAt),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      ),
    );
  }

  Widget _outfitFullImage(Outfit outfit, BuildContext context) {
    return Container(
      width: 120,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 3,
            offset: Offset(0, 1.5)
          )
        ]
      ),
      child: Hero(
        tag: outfit.images.first,  
        child: CachedNetworkImage(
          imageUrl: outfit.images[0],
          fit: BoxFit.fitHeight,
          fadeInDuration: Duration(),
        ),
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