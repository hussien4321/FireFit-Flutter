import 'package:flutter/material.dart';
import 'package:middleware/middleware.dart';
import 'dart:ui';
import 'package:blocs/blocs.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:front_end/screens.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';

class OutfitFadingCard extends StatefulWidget {
  final Outfit currentOutfit;
  final Outfit nextOutfit;
  final double thickness;
  final VoidCallback onNextPicShown;
  final Color backgroundColor;
  final bool isLoading;
  final bool enabled;

  OutfitFadingCard({
    this.currentOutfit,
    this.nextOutfit,
    this.thickness = 6,
    this.onNextPicShown,
    this.backgroundColor,
    this.isLoading,
    this.enabled = true,
  });

  @override
  _OutfitFadingCardState createState() => _OutfitFadingCardState();
}

class _OutfitFadingCardState extends State<OutfitFadingCard> with SingleTickerProviderStateMixin {

  int currentOutfitId;

  double thickness;
  AnimationController blurringTransitionController;
  
  final double maxBlurSigma = 10.0;
  @override
  void initState() {
    thickness = widget.thickness;
    currentOutfitId = widget.currentOutfit?.outfit_id;
    blurringTransitionController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..addListener(() => setState((){}))
    ..addStatusListener((status) {
      if(status == AnimationStatus.completed){
        blurringTransitionController.reverse();
        currentOutfitId = (currentOutfitId == widget.currentOutfit?.outfit_id) ? widget.nextOutfit?.outfit_id : widget.currentOutfit?.outfit_id;
      }
      if(status ==AnimationStatus.dismissed){
        widget.onNextPicShown();
      }
    });
    super.initState();
  }

  bool get haveOutfit => _currentOutfit != null;

  @override
  void dispose() {
    blurringTransitionController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(OutfitFadingCard oldWidget) {
    if(oldWidget.currentOutfit?.outfit_id != widget.currentOutfit?.outfit_id){
      setState(() {
       currentOutfitId = widget.currentOutfit?.outfit_id; 
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        children: <Widget>[
          Expanded(
            child: _buildOutfitSplash(),
          ),
          _buildOutfitInfo(),
        ],
      ),
    );
  }

  Widget _buildOutfitSplash() {
    return GestureDetector(
      onVerticalDragUpdate: widget.enabled ? (s) => _switchToNextImage() : null,
      onTap: widget.enabled && haveOutfit ? openDetailedImage : null,
      child: Hero(
        tag: widget.currentOutfit?.images?.first == null? 'NULL' : widget.currentOutfit?.images?.first,
        child: Stack(
          children: <Widget>[
            _buildPicture(widget.currentOutfit),
            _buildPicture(widget.nextOutfit),
            SizedBox.expand(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: _blurValue, sigmaY: _blurValue),
                child: Container(
                  color: Colors.grey.withOpacity(blurringTransitionController.value/4),
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPicture(Outfit outfit) {
    if(outfit == null){
      return Opacity(
        opacity: currentOutfitId == null ? 1.0 : 0.0,
        child: widget.isLoading ? _buildLoading() : _buildCompleted()
      );
    }
    return Opacity(
      opacity: currentOutfitId == outfit.outfit_id ? 1.0 : 0.0,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 1),
              blurRadius: 2,
              color: Colors.black54
            )
          ],
          color: Colors.white,
        ),
        child: Stack(
            children: <Widget>[
              SizedBox.expand(
                child: CachedNetworkImage(
                  imageUrl: outfit.images.first,
                  fadeInDuration: Duration(milliseconds: 0),
                  fit: BoxFit.cover,
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.grey.withOpacity(0.0),
                )
              ),
              SizedBox.expand(
                child: CachedNetworkImage(
                  imageUrl: outfit.images.first,
                  fit: BoxFit.fitHeight,
                ),
              ),
              outfit.hasMultipleImages? _displayMultiPicIndicator() : Container(),
            ],
          ),
      ),
    );
  }

  Widget _displayMultiPicIndicator() {
    return Positioned(
      right: 8,
      bottom: 8,
      child: Container(
        padding: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(8.0)
        ),
        child: Icon(
          Icons.photo_library,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Theme(
              data: ThemeData(accentColor: Colors.blue),
              child: CircularProgressIndicator(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Finding awesome outfits...',
                style: Theme.of(context).textTheme.subhead.apply(color: Colors.blue),
              ),
            ),
          ],
        )
      )
    );
  }

  Widget _buildCompleted() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              FontAwesomeIcons.sadCry,
              color: Colors.pink,
              size: 48,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No more outfits to show...\n\nRefresh your search or try a different filter to discover new styles!',
                style: Theme.of(context).textTheme.subhead.apply(color: Colors.pink),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        )
      )
    );
  }



  _switchToNextImage() {
    if(haveOutfit){
      if(!blurringTransitionController.isAnimating){
        blurringTransitionController.forward();
      }
    }
  }

  openDetailedImage(){
    if(haveOutfit){
      Navigator.push(context, MaterialPageRoute(
        //TODO: CREATE NEW TRANSITION THAT FADES CURRENT PAGE TO WHITE THEN FADES IN NEXT PAGE
        builder: (context) => OutfitDetailsScreen(outfitId: widget.currentOutfit.outfit_id)
      ));
    }
  }

  Widget _buildOutfitInfo() {
    if(!haveOutfit) {
      return Container();
    }
    return Padding(
      padding: EdgeInsets.only(top: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Opacity(
            opacity: _infoOpacityValue,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: Colors.transparent,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Transform.translate(
                    offset: Offset(_infoSlideValue ,0 ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              _currentOutfit.title,
                              style: Theme.of(context).textTheme.title,
                            ),
                          ),
                          Icon(
                            _currentOutfit.poster.genderIsMale ? FontAwesomeIcons.male : FontAwesomeIcons.female,
                            color: Colors.black,
                          ),
                          Text(
                            _currentOutfit.poster.ageRange,
                            style: Theme.of(context).textTheme.title.apply(color: Colors.black),
                          )
                        ],
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(_infoSlideValue,0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            _currentOutfit.style,
                            style:TextStyle(
                              fontStyle: FontStyle.italic,
                              letterSpacing: 1.5,
                            ),
                          )
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                '${_currentOutfit.commentsCount} ',
                                style: Theme.of(context).textTheme.subtitle,
                              ),
                              Icon(
                                Icons.comment,
                                size: 16,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '${_currentOutfit.likesOverallCount} ',
                              style: Theme.of(context).textTheme.subtitle,
                            ),
                            Icon(
                              Icons.thumbs_up_down,
                              size: 16,
                              color: Colors.black,
                            ),
                          ]
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Outfit get _currentOutfit => currentOutfitId == widget.currentOutfit?.outfit_id ? widget.currentOutfit : widget.nextOutfit;

  double get _blurValue => Tween<double>(
    begin: 0.0,
    end: maxBlurSigma
  ).lerp(blurringTransitionController.value);

  double get _infoOpacityValue => (1-blurringTransitionController.value*1.5).clamp(0.0,1.0);
  double get _infoSlideValue => (blurringTransitionController.status == AnimationStatus.forward ? 1 : -1) * blurringTransitionController.value * 60 ;
}
