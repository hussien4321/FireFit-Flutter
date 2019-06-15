import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:middleware/middleware.dart';
import 'package:front_end/screens.dart';

class OutfitsGrid extends StatelessWidget {

  final bool isLoading;
  final List<Outfit> outfits;
  final bool hideTitle;

  OutfitsGrid({this.outfits, this.isLoading, this.hideTitle = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8,horizontal: 4.0),
      width: double.infinity,
      child: outfits.isEmpty && !isLoading ? _buildNoOutfitsMessage() : _buildScrollableGrid(context)
      
    );
  }

  Widget _buildNoOutfitsMessage() {
    return Center(
      child: Text(
        'You have no outfits saved, check the inspiration page for new outfit ideas to save!'
      ),
    );
  }

  Widget _buildScrollableGrid(BuildContext ctx) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          hideTitle ? Container():  Container(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              '${outfits.length} OUTFIT${outfits.length==1?'':'S'}',
              style: Theme.of(ctx).textTheme.subhead,
            ),
          ),
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
            itemBuilder: (ctx, i) => _buildSimpleOutfitView(outfits[i], ctx),
          ),
          Container(
            padding: EdgeInsets.all(4.0),
            child: isLoading ? CircularProgressIndicator() : Container()
          )
        ],
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
      builder: (context) => OutfitDetailsScreen(outfitId: outfit.outfitId)
    ));
  }

}