import 'package:flutter/material.dart';
import 'package:middleware/middleware.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:helpers/helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OutfitMainCard extends StatelessWidget {

  final Outfit outfit;

  OutfitMainCard({this.outfit});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: GestureDetector(
        onTap: () => _openOutfit(context, outfit),
        child: Stack(
          children: <Widget>[
            _outfitImage(outfit),
            _outfitBasicInfo(context, outfit),
            _outfitTags(outfit),
          ],
        ),
      ),
    );
  }

  

  _openOutfit(BuildContext context, Outfit outfit) {
    CustomNavigator.goToOutfitDetailsScreen(context, outfitId: outfit.outfitId);
  }

  Widget _outfitImage(Outfit outfit){
    return Hero(
      tag: outfit.images.first,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: CachedNetworkImageProvider(outfit.images.first)
          ),
        ),
      ),
    );
  }
  Widget _outfitBasicInfo(BuildContext context, Outfit outfit){
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.only(left: 8, bottom: 8, right: 8, top: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.black87
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    outfit.title,
                    style: Theme.of(context).textTheme.subhead.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.start,
                    softWrap: true,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
            OutfitStats(outfit: outfit, size: 16,),
          ],
        ),
      ),
    );
  } 
  Widget _outfitTags(Outfit outfit){
    List<Widget> tags = [];
    if(outfit.hasMultipleImages){
      tags.add(
        Icon(
          Icons.photo_library,
          color: Colors.white,
          size: 16,
        )
      );
    }
    if(outfit.hasDescription){
      tags.add(
        Icon(
          Icons.subject,
          color: Colors.white,
          size: 16,
        )
      );
    }
    return !outfit.hasAdditionalInfo ? Container() : Align(
      alignment: Alignment.topRight,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4))
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: tags,
        ),
      ),
    );
  } 
}