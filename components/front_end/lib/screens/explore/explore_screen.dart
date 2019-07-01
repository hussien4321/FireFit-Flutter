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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin{
  
  final Color imageOverlayColor = Colors.white;

  LoadOutfits explore = LoadOutfits();
  String userId;

  int adCounter = 50;

  bool isPaginationDropdownInFocus = false;
  bool isFilterDropdownInFocus = false;
  bool get isAnyDropdownInFocus => isPaginationDropdownInFocus || isFilterDropdownInFocus;

  OutfitBloc _outfitBloc;
  
  int index = 0;

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
            Expanded(
              child: StreamBuilder<bool>(
                stream: _outfitBloc.isLoading,
                initialData: true,
                builder: (ctx, isLoadingSnap) => StreamBuilder<List<Outfit>>(
                  stream: _outfitBloc.exploredOutfits,
                  initialData: [],
                  builder: (ctx, outfitsSnap) {
                    return _outfitsCarousel(outfitsSnap.data, isLoadingSnap.data);
                  }
                )
              )
            ),
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
            onPressed: _openFilters,
            icon: Icon(Icons.tune),
          ),
        ],
      ),
    );
  }

  _openFilters(){
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Still in progress'),
        content: Text('Filters coming soon!'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Close',
              style: TextStyle(
                inherit: true,
                color: Colors.deepOrange,
              ),
            ),
            onPressed: Navigator.of(ctx).pop,
          )
        ],
      )
    );
  }

  Widget _outfitsCarousel(List<Outfit> outfits, bool isLoading) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CarouselSlider(
              height: double.infinity,
              enlargeCenterPage: true,
              onPageChanged: (i) {
                setState(() => index = i);
                if(i+1>=outfits.length){
                  _outfitBloc.exploreOutfits.add(LoadOutfits(
                    userId: userId,
                    startAfterOutfit: outfits.last
                  ));
                }
              },
              items: outfits.map((outfit) => _buildOutfitCard(outfit, index)).toList()..add(_endCard(isLoading)),
              enableInfiniteScroll: false,
              viewportFraction: 0.8,
            ),
          )
        ),
        _fireButton(outfits, index),
      ],
    );
                     
  }

  Widget _buildOutfitCard(Outfit outfit, int index) {
    return _card(
      child: GestureDetector(
        onTap: () => _openOutfit(outfit),
        child: Stack(
          children: <Widget>[
            _outfitImage(outfit),
            _outfitBasicInfo(outfit),
          ],
        ),
      ),
    );
  }

  Widget _card({Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Align(
        alignment: Alignment.center,
        child: AspectRatio(
          aspectRatio: 2/3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: child
          )
        )
      )
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

  Widget _endCard(bool isLoading) {
    return _card(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey[300],
              Colors.black54
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              isLoading? 
              Theme(
                data: ThemeData(
                  accentColor: Colors.white
                ),
                child: CircularProgressIndicator()
              ) : Icon(
                FontAwesomeIcons.boxOpen,
                color: Colors.white,
                size: 48,
              ),
              Text(isLoading ? 'Loading Fits' : 'No more items',
                style: Theme.of(context).textTheme.display1.copyWith(
                  color: Colors.white
                ),
                textAlign: TextAlign.center,
              ),
              Text(isLoading ? 'Please wait while we find you more fire fits!' : 'Try a different search filter or refresh the page to see new fits!',
                style: Theme.of(context).textTheme.subtitle.copyWith(
                  color: Colors.white
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      )
    );
  }

  Widget _fireButton(List<Outfit> outfits, int index) {
    Outfit currentOutfit = outfits.length <= index ? null : outfits[index];
    bool hasOutfit =currentOutfit != null;
    bool hasRating =currentOutfit?.hasRating == true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            fillColor: !hasOutfit ? Colors.grey : hasRating ? Colors.red[900] : Colors.lightBlue,
            elevation: hasRating ? 0 : 2,
            shape: CircleBorder(),
            onPressed: currentOutfit == null ? null : () => _giveRating(currentOutfit),
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

  _giveRating(Outfit currentOutfit) {
    return showDialog(
      context: context,
      builder: (ctx) {
        return RatingDialog(
          initialValue: currentOutfit.userRating,
          isUpdate: currentOutfit.hasRating,
          onSubmit: (newRating) {
            OutfitRating outfitRating = OutfitRating(
              outfit: currentOutfit,
              ratingValue: newRating,
              userId: userId,
            );
            _outfitBloc.rateOutfit.add(outfitRating);
          }
        );
      }
    );
  }
}

