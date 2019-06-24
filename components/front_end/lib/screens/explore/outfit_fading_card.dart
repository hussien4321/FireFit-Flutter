import 'package:flutter/material.dart';
import 'package:middleware/middleware.dart';
import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:flutter/gestures.dart';
import 'dart:math';

class OutfitFadingCard extends StatefulWidget {
  final Outfit previousOutfit;
  final Outfit currentOutfit;
  final Outfit nextOutfit;
  final double thickness;
  final VoidCallback onNextPicShown;
  final VoidCallback onPrevPicShown;
  final Color backgroundColor;
  final bool isLoading;
  final bool enabled;
  final ValueChanged<bool> onPageSwitch;

  OutfitFadingCard({
    this.previousOutfit,
    this.currentOutfit,
    this.nextOutfit,
    this.thickness = 6,
    this.onNextPicShown,
    this.onPrevPicShown,
    this.backgroundColor,
    this.isLoading,
    this.onPageSwitch,
    this.enabled = true,
  });

  @override
  _OutfitFadingCardState createState() => _OutfitFadingCardState();
}

class _OutfitFadingCardState extends State<OutfitFadingCard> with SingleTickerProviderStateMixin {

  int currentOutfitId;

  double thickness;
  AnimationController blurringTransitionController;

  Offset dragStartPos;
  double percentageOfBlur = 0;
  bool isDraggingForward = true;
  bool hasSwitchedOutfits = false;
  bool hasPassedDragThreshold = false;
  

  final double maxBlurSigma = 10.0;
  @override
  void initState() {
    thickness = widget.thickness;
    currentOutfitId = widget.currentOutfit?.outfitId;
    blurringTransitionController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    )..addListener(() => setState((){}))
    ..addStatusListener((status) {
      if(status == AnimationStatus.completed){
        blurringTransitionController.reverse();
        _switchOutfits();
        hasSwitchedOutfits = true;
      }
      if(status ==AnimationStatus.dismissed){
        if(hasSwitchedOutfits){
          if(isDraggingForward){
            widget.onNextPicShown();
          }else{
            widget.onPrevPicShown();
          }
          hasSwitchedOutfits=false;
          isDraggingForward=true;
        }
      }
    });
    super.initState();
  }

  _switchOutfits() {
    setState(() {
      currentOutfitId = (currentOutfitId == widget.currentOutfit?.outfitId) ? (isDraggingForward ? widget.nextOutfit?.outfitId :  widget.previousOutfit?.outfitId) : widget.currentOutfit?.outfitId;
    });
  }

  @override
  void dispose() {
    blurringTransitionController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(OutfitFadingCard oldWidget) {
    if(oldWidget.currentOutfit?.outfitId != widget.currentOutfit?.outfitId){
      setState(() {
       currentOutfitId = widget.currentOutfit?.outfitId; 
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: _buildTouchDetector(
        child: Column(
          children: <Widget>[
            Expanded(
              child: _buildOutfitSplash(),
            ),
            _buildOutfitInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildTouchDetector({Widget child}) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: child,
    );
  }

  _onDragStart(DragStartDetails details) {
    dragStartPos = details.globalPosition;
  }

  _onDragUpdate(DragUpdateDetails details) {
    Offset overallDelta = details.globalPosition - dragStartPos;
    percentageOfBlur = overallDelta.dx / (screenWidth/2);
    
    hasPassedDragThreshold = (overallDelta.dx/dragThreshold).abs() > 1;
    
    isDraggingForward = percentageOfBlur >= 0;

    _zeroDragIfNoMoreItems();

    percentageOfBlur=percentageOfBlur.abs();

    percentageOfBlur*=2;
    percentageOfBlur=min(percentageOfBlur, 1.99);

    bool latestHasSwitchedOutfits = percentageOfBlur>1;
    if(percentageOfBlur>1){
      percentageOfBlur = 2-percentageOfBlur;
    }
    if(latestHasSwitchedOutfits!=hasSwitchedOutfits){
      _switchOutfits();
      bool isSwipingForward1 = latestHasSwitchedOutfits && isDraggingForward;
      bool isSwipingForward2 = !latestHasSwitchedOutfits && !isDraggingForward;
      widget.onPageSwitch(isSwipingForward1 || isSwipingForward2);
    }
    hasSwitchedOutfits=latestHasSwitchedOutfits;
    setState(() {
     blurringTransitionController.value =percentageOfBlur;
    });
  }

  
  _zeroDragIfNoMoreItems(){
    bool hasNoMoreBackDrag = !isDraggingForward && !hasPrevious;
    bool hasNoMoreForwardDrag = isDraggingForward && !hasCurrent;
    if(hasNoMoreBackDrag || hasNoMoreForwardDrag){
      percentageOfBlur=0;
      hasPassedDragThreshold = false;
    }
  }

  _onDragEnd(DragEndDetails details) {
    percentageOfBlur = 0;
    if(hasPassedDragThreshold && !hasSwitchedOutfits){
      blurringTransitionController.forward();
    }else{
      blurringTransitionController.reverse();
    }
  }

  bool get hasPrevious => widget.previousOutfit != null;
  bool get hasCurrent => widget.currentOutfit != null;
  bool get hasOutfit => _currentOutfit != null;

  double get screenWidth => context.size.width;
  double get dragThreshold => screenWidth/5;

  Widget _buildOutfitSplash() {
    return GestureDetector(
      onTap: widget.enabled && hasOutfit? _openDetailedOutfit : null,
      child: Hero(
        tag: widget.currentOutfit?.images?.first == null? 'NULL' : widget.currentOutfit?.images?.first,
        child: Stack(
          children: <Widget>[
            _buildPicture(widget.previousOutfit),
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
      opacity: currentOutfitId == outfit.outfitId ? 1.0 : 0.0,
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
              FitHeightBlurImage(
                url: outfit.images.first,
              ),
              outfit.hasAdditionalInfo? _displayMultiPicIndicator(outfit) : Container(),
            ],
          ),
      ),
    );
  }


  Widget _displayMultiPicIndicator(Outfit outfit) {
    return Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(4.0)
          )
        ),
        child: Row(
          children: <Widget>[
            outfit.hasDescription ? Icon(
              Icons.description,
              color: Colors.white,
            ) : Container(),
            outfit.hasMultipleImages ? Icon(
              Icons.photo_library,
              color: Colors.white,
            ) : Container(),
          ],
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



  _openDetailedOutfit(){
    if(hasOutfit){
      CustomNavigator.goToOutfitDetailsScreen(context, false, 
        outfitId: widget.currentOutfit.outfitId
      );
    }
  }

  Widget _buildOutfitInfo() {
    if(!hasOutfit) {
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
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
                          DemographicSticker(_currentOutfit.poster),
                        ],
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(_infoSlideValue,0),
                    child: OutfitStats(outfit: _currentOutfit),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Outfit get _currentOutfit => currentOutfitId == widget.currentOutfit?.outfitId ? widget.currentOutfit : (isDraggingForward ? widget.nextOutfit : widget.previousOutfit);

  double get _blurValue => Tween<double>(
    begin: 0.0,
    end: maxBlurSigma
  ).lerp(blurringTransitionController.value);

  double get _infoOpacityValue => (1-blurringTransitionController.value*1.5).clamp(0.0,1.0);
  double get _infoSlideValue => (isDraggingForward ? (hasSwitchedOutfits ? -1 : 1) : (hasSwitchedOutfits ? 1 : -1)) * blurringTransitionController.value * 60 ;
}
