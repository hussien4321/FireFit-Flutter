import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:blocs/blocs.dart';
import 'package:middleware/middleware.dart';
import 'package:front_end/providers.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:front_end/screens.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  
  final Color imageOverlayColor = Colors.white;

  LoadOutfits explore = LoadOutfits();
  String userId;

  int adCounter = 50;

  bool isPaginationDropdownInFocus = false;
  bool isFilterDropdownInFocus = false;
  bool get isAnyDropdownInFocus => isPaginationDropdownInFocus || isFilterDropdownInFocus;

  OutfitBloc _outfitBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _initBlocs();
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))
        ),
        padding: EdgeInsets.only(top: 16.0),
        child: Column(
          children: <Widget>[
            _searchDetailsBar(),
            Expanded(child: _outfitsCarousel()),
            _fireButton(),
          ],
        )
      ),
    );
  }


  _initBlocs() async {
    if(_outfitBloc==null){
      _outfitBloc = OutfitBlocProvider.of(context);
      userId = await UserBlocProvider.of(context).existingAuthId.first;
      explore.userId = userId;
      _outfitBloc.exploreOutfits.add(explore);
    }
  }

  Widget _searchDetailsBar(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Freshest Fits',
                  style: Theme.of(context).textTheme.display1.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Text(
                  'Most recently uploaded outfits!',
                  style: Theme.of(context).textTheme.caption.copyWith(
                    fontStyle: FontStyle.italic
                  ),
                ),
              ],
            )
          ),
          IconButton(
            onPressed: (){},
            icon: Icon(Icons.tune),
          ),
        ],
      ),
    );
  }

  Widget _outfitsCarousel() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: StreamBuilder<bool>(
        stream: _outfitBloc.isLoading,
        initialData: true,
        builder: (ctx, isLoadingSnap) => StreamBuilder<List<Outfit>>(
          stream: _outfitBloc.exploredOutfits,
          initialData: [],
          builder: (ctx, outfitsSnap) {
            return CarouselSlider(
              height: double.infinity,
              enlargeCenterPage: true,
              items: outfitsSnap.data.map((outfit) => _buildOutfitCard(outfit)).toList(),
              enableInfiniteScroll: false,
              viewportFraction: 0.8,
            );
          }, 
        ),
      ),
    );
  }

  Widget _buildOutfitCard(Outfit outfit) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Align(
        alignment: Alignment.center,
        child: AspectRatio(
          aspectRatio: 2/3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: GestureDetector(
              onTap: () => _openOutfit(outfit),
              child: Stack(
                children: <Widget>[
                  _outfitImage(outfit),
                  _outfitBasicInfo(outfit)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _openOutfit(Outfit outfit) {
    Navigator.push(context, MaterialPageRoute(
      builder: (ctx) => OutfitDetailsScreen(
        outfitId: outfit.outfitId,
      )
    ));
  }

  Widget _outfitImage(Outfit outfit){
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: CachedNetworkImageProvider(outfit.images.first)
        ),
      ),
    );
  }
  Widget _outfitBasicInfo(Outfit outfit){
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.black26
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
          ),
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  outfit.title,
                  style: Theme.of(context).textTheme.display1.copyWith(
                    color: Colors.white
                  ),
                  textAlign: TextAlign.start,
                  softWrap: true,
                  overflow: TextOverflow.fade,
                ),
              ),
              outfit.hasMultipleImages ? Icon(
                Icons.photo_library,
                color: Colors.white,
              ) : Container(),
            ],
          ),
        ),
      ),
    );
  } 

  Widget _fireButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            fillColor: Colors.lightBlue,
            elevation: 0,
            shape: CircleBorder(),
            onPressed: (){},
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/flame.png',
                width: 32,
                height: 32,
              ),
            )
          )
        ],
      ),
    );
  }

  Widget _ratingSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlutterRatingBar(
            initialRating: 5,
            itemCount: 5,
            allowHalfRating: true,
            itemSize: 32,
            fullRatingWidget: Image.asset(
              'assets/flame.png',
              width: 32,
              height: 32,
            ),
            noRatingWidget: Container(
              width: 32,
              height: 32,
            ),
          ),
        ],
      ),
    );
  }

}