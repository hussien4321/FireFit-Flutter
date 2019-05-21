import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:front_end/screens.dart';
import 'package:blocs/blocs.dart';
import 'package:middleware/middleware.dart';
import 'package:front_end/providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  
  final Color imageOverlayColor = Colors.white;

  // List<Outfit> outfits = mockedOutfits;

  int pageNumber = 1;
  int currentIndex=0;
  int nextIndex=1;

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
        child: _buildOutfitLiveStream()
      ),
    );
  }

  _initBlocs() {
    if(_outfitBloc==null){
      _outfitBloc = OutfitBlocProvider.of(context);
      _outfitBloc.exploreOutfits.add(null);
    }
  }

  Widget _buildOutfitLiveStream() {
    return StreamBuilder<bool>(
      stream: _outfitBloc.isLoading,
      initialData: true,
      builder: (ctx, loadingSnap) {
        return StreamBuilder<List<Outfit>>(
          stream: _outfitBloc.outfits,
          initialData: [],
          builder: (ctx, snap) {
            List<Outfit> outfits = snap.data;
            return Stack(
              children: <Widget>[
                _buildOutfitViewAndOptions(
                  outfitView: OutfitDisplayer(
                    currentOutfit: outfitAtIndex(outfits, currentIndex),
                    nextOutfit: outfitAtIndex(outfits, nextIndex),
                    thickness: 10,
                    onNextPicShown: () => _incrementIndexes(outfits),
                    backgroundColor: imageOverlayColor,
                    isLoading: loadingSnap.data,
                  ),
                  options: _buildActionBar(),
                ),
                _searchManipulatorButtons(),
              ],
            );
          }
        );
      }
    );
  }

  Widget _buildOutfitViewAndOptions({
    Widget outfitView,
    Widget options,
  }){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 2,
            offset: Offset(0, -1)
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        child: Container(
          color: imageOverlayColor,
          child: Column(
            children: <Widget>[
              Expanded(
                child: outfitView
              ),
              options,
            ],
          ),
        ),
      ),
    );
  }

  Outfit outfitAtIndex(List<Outfit> allOutfits, int index) {
    if(allOutfits == null || allOutfits.length <= index){
      return null;
    }
    return allOutfits[index];
  }

  Widget _searchManipulatorButtons(){
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        RawMaterialButton(
          onPressed: () {},
          fillColor: Colors.black45,
          child: Text(
            '$pageNumber',
            style: Theme.of(context).textTheme.subtitle.apply(color: Colors.white),
          ),
          shape: CircleBorder(),
        ),
        RawMaterialButton(
          onPressed: () {},
          fillColor: Colors.black45,
          child: Icon(
            Icons.tune,
            color: Colors.white,
          ),
          shape: CircleBorder(),
          elevation: 10.0,
        ),
      ],
    );
  }

  _incrementIndexes(List<Outfit> outfits){
    setState(() {
      currentIndex = nextIndex;
      nextIndex = nextIndex+1; 
      pageNumber = pageNumber+1;
    });
  }

  Widget _buildActionBar() {
    return Container(
      color: imageOverlayColor,
      padding: EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0, top: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildSingleAction(
            color: Colors.red,
            splashColor: Colors.amberAccent,
            icon: Icons.report,
            onPressed: () {},
          ),
          _buildSingleAction(
            color: Colors.pinkAccent,
            splashColor: Colors.amberAccent,
            icon: Icons.thumb_down,
            largeIcon: true,
            disabled: true,
            onPressed: () {},
          ),
          _buildSingleAction(
            color: Colors.greenAccent[700],
            splashColor: Colors.amberAccent,
            icon: Icons.comment,
            onPressed: () {},
          ),
          _buildSingleAction(
            color: Colors.blueAccent,
            splashColor: Colors.amberAccent,
            icon: Icons.thumb_up,
            largeIcon: true,
            selected: true,
            onPressed: () {},
          ),
          _buildSingleAction(
            color: Colors.amberAccent,
            splashColor: Colors.amberAccent,
            icon: Icons.star,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSingleAction({
    Color color,
    Color splashColor,
    IconData icon,
    bool largeIcon = false,
    VoidCallback onPressed,
    bool selected= false,
    bool disabled = false,
  }){
    double iconSize = largeIcon ? 30.0 : 24.0;
    double padding = largeIcon ? 8.0 : 6.0;
    return Container(
      width: iconSize + padding*2,
      height: iconSize + padding*2, 
      decoration: BoxDecoration(
        color: selected ? color : 
          disabled ? Colors.grey : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 3.0,
            offset: Offset(0.0, 3)
          )
        ]
      ),
      child: IconButton(
        color: selected || disabled ? Colors.white : color,
        padding: EdgeInsets.all(padding),
        icon: Icon(icon),
        iconSize: iconSize,
        onPressed: onPressed,
      ),
    );
  }
}

class OutfitDisplayer extends StatefulWidget {
  final Outfit currentOutfit;
  final Outfit nextOutfit;
  final double thickness;
  final VoidCallback onNextPicShown;
  final Color backgroundColor;
  final bool isLoading;

  OutfitDisplayer({
    this.currentOutfit,
    this.nextOutfit,
    this.thickness = 6,
    this.onNextPicShown,
    this.backgroundColor,
    this.isLoading,
  });

  @override
  _OutfitDisplayerState createState() => _OutfitDisplayerState();
}

class _OutfitDisplayerState extends State<OutfitDisplayer> with SingleTickerProviderStateMixin {

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
  void didUpdateWidget(OutfitDisplayer oldWidget) {
    if(oldWidget.currentOutfit?.outfit_id != widget.currentOutfit?.outfit_id){
      setState(() {
       currentOutfitId = widget.currentOutfit?.outfit_id; 
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          _buildOutfitSplash(),
          _buildOutfitInfo(),
        ],
      ),
    );
  }

  Widget _buildOutfitSplash() {
    return GestureDetector(
      onVerticalDragUpdate: (s) => _switchToNextImage(),
      onTap: haveOutfit ? openDetailedImage : null,
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
      child: Stack(
          children: <Widget>[
            SizedBox.expand(
              child: Image.network(
                outfit.images.first,
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
          ],
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
        builder: (context) => OutfitDetailsScreen(outfit: widget.currentOutfit)
      ));
    }
  }

  Widget _buildOutfitInfo() {
    if(!haveOutfit) {
      return Container();
    }
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height:250,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              widget.backgroundColor,
            ],
            stops: [0.5,1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Container(),
            ),
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
                              '${_currentOutfit.poster.age}',
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
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Style: ',
                                    style: Theme.of(context).textTheme.subtitle,
                                  ),
                                  TextSpan(
                                    text: _currentOutfit.style,
                                    style: Theme.of(context).textTheme.body1,
                                  )
                                ]
                              ),
                            ),
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
                                '${_currentOutfit.likesCount} ',
                                style: Theme.of(context).textTheme.subtitle,
                              ),
                              Icon(
                                Icons.thumb_up,
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
