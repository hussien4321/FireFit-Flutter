import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:middleware/middleware.dart';
import 'package:front_end/screens.dart';

class OutfitsGrid extends StatelessWidget {

  final bool isLoading;
  final List<Outfit> outfits;

  OutfitsGrid({this.outfits, this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8,horizontal: 4.0),
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.5,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4
              ),
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemCount: outfits.length,
              itemBuilder: (ctx, i) => _buildSimpleOutfitView(outfits[i], context),
            ),
            Container(
              padding: EdgeInsets.all(4.0),
              child: isLoading ? CircularProgressIndicator() : Container()
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleOutfitView(Outfit outfit, BuildContext ctx) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black45,
          width: 0.5
        )
      ),
      child: GestureDetector(
        onTap: () => _openDetailedOutfit(outfit, ctx),
        child: Hero(
          tag: outfit.images.first,  
          child: CachedNetworkImage(
            imageUrl: outfit.images[0],
            fit: BoxFit.fitHeight,
          ),
        ),
      ),
    );
  }

  _openDetailedOutfit(Outfit outfit, BuildContext ctx){
    Navigator.push(ctx, MaterialPageRoute(
      builder: (context) => OutfitDetailsScreen(outfitId: outfit.outfit_id)
    ));
  }

}