import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mira_mira/screens.dart';
import 'package:mira_mira/helper_widgets.dart';
import 'package:data_handler/data_handler.dart';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  
  List<Outfit> outfits = mockedOutfits;

  int currentIndex=0;
  int nextIndex=1;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _searchTerms(),
            Expanded(
              child: MagicMirror(
                currentOutfit: outfits[currentIndex],
                nextOutfit: outfits[nextIndex],
                thickness: 10,
                onNextPicShown: _incrementIndexes,
              ),
            ),
            _buildActionBar(),
          ],
        )
      ),
    );
  }

  //TODO: OADD DIALOGS FOR TERMS
  Widget _searchTerms(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Material(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.orangeAccent,
          elevation: 3.0,
          child: InkWell(
            borderRadius: BorderRadius.circular(10.0),
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Style: ',
                      style: Theme.of(context).textTheme.subtitle
                    ),
                    TextSpan(
                      text: 'All',//TODO: DESIGN UI FOR STYLES (WHEEL??)
                      style: Theme.of(context).textTheme.body1
                    )
                  ]
                ),
              )
            ),
          ),
        ),
        Material(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.amberAccent,
          elevation: 3.0,
          child: InkWell(
            borderRadius: BorderRadius.circular(10.0),
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Sort by: ',
                      style: Theme.of(context).textTheme.subtitle
                    ),
                    TextSpan(
                      text: 'Newest',
                      style: Theme.of(context).textTheme.body1
                    )
                  ]
                ),
              )
            ),
          ),
        ),
      ],
    );
  }


  _incrementIndexes(){
    setState(() {
      currentIndex = nextIndex;
      nextIndex = nextIndex==outfits.length-1? 0 : nextIndex+1; 
    });
  }

  Widget _buildActionBar() {
    return Padding(
      padding: EdgeInsets.all(0.0),
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

class MagicMirror extends StatefulWidget {
  final Outfit currentOutfit;
  final Outfit nextOutfit;
  final double thickness;
  final VoidCallback onNextPicShown;

  MagicMirror({
    this.currentOutfit,
    this.nextOutfit,
    this.thickness = 6,
    this.onNextPicShown,
  });

  @override
  _MagicMirrorState createState() => _MagicMirrorState();
}

class _MagicMirrorState extends State<MagicMirror> with SingleTickerProviderStateMixin {

  int currentOutfitId;

  double thickness;
  AnimationController blurringTransitionController;
  
  final double maxBlurSigma = 10.0;

  @override
  void initState() {
    thickness = widget.thickness;
    currentOutfitId = widget.currentOutfit.id;
    blurringTransitionController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..addListener(() => setState((){}))
    ..addStatusListener((status) {
      if(status == AnimationStatus.completed){
        blurringTransitionController.reverse();
        currentOutfitId = (currentOutfitId == widget.currentOutfit.id) ? widget.nextOutfit.id : widget.currentOutfit.id;
      }
      if(status ==AnimationStatus.dismissed){
        widget.onNextPicShown();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    blurringTransitionController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MagicMirror oldWidget) {
    if(oldWidget.currentOutfit.id != widget.currentOutfit.id){
      setState(() {
       currentOutfitId = widget.currentOutfit.id; 
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onVerticalDragUpdate: (s) => _switchToNextImage(),
                      onTap: openDetailedImage,
                      child: Hero(
                        tag:widget.currentOutfit.images.first,
                        child: MirrorFrame( 
                          child: Stack(
                            children: <Widget>[
                              _buildPicture(widget.currentOutfit),
                              _buildPicture(widget.nextOutfit),
                              SizedBox.expand(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: _blurValue, sigmaY: _blurValue),
                                  child: Container(
                                    color: Color.fromRGBO(204, 187, 187, 0.0),
                                  )
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildOutfitInfo(),
        ],
      ),
    );
  }

  Widget _buildPicture(Outfit outfit) {
    return Opacity(
      opacity: currentOutfitId == outfit.id ? 1.0 : 0.0,
      child: SizedBox.expand(
        child: Image.asset(
          outfit.images.first,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  _switchToNextImage() {
    if(!blurringTransitionController.isAnimating){
      blurringTransitionController.forward();
    }
  }

  openDetailedImage(){
    Navigator.push(context, MaterialPageRoute(
      //TODO: CREATE NEW TRANSITION THAT FADES CURRENT PAGE TO WHITE THEN FADES IN NEXT PAGE
      builder: (context) => OutfitDetailsScreen(outfit: widget.currentOutfit)
    ));
  }

  Widget _buildOutfitInfo() {
    return Opacity(
      opacity: _infoOpacityValue,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: Colors.transparent,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Transform.translate(
              offset: Offset(_infoSlideUpValue ,0 ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _currentOutfit.name,
                        style: Theme.of(context).textTheme.title,
                      ),
                    ),
                    Icon(
                      _currentOutfit.poster.genderIsMale ? FontAwesomeIcons.male : FontAwesomeIcons.female,
                      color: Colors.grey,
                    ),
                    Text(
                      '${_currentOutfit.poster.age}',
                      style: Theme.of(context).textTheme.title.apply(color: Colors.grey),
                    )
                  ],
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(_infoSlideUpValue,0),
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
                          style: Theme.of(context).textTheme.subtitle.apply(color: Color.fromRGBO(208, 160, 88, 1.0)),
                        ),
                        Icon(
                          Icons.comment,
                          size: 16,
                          color: Color.fromRGBO(208, 160, 88, 1.0),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '${_currentOutfit.likesCount} ',
                        style: Theme.of(context).textTheme.subtitle.apply(color: Color.fromRGBO(208, 160, 88, 1.0)),
                      ),
                      Icon(
                        Icons.thumb_up,
                        size: 16,
                        color: Color.fromRGBO(208, 160, 88, 1.0),
                      ),
                    ]
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Outfit get _currentOutfit => currentOutfitId == widget.currentOutfit.id ? widget.currentOutfit : widget.nextOutfit;

  double get _blurValue => Tween<double>(
    begin: 0.0,
    end: maxBlurSigma
  ).lerp(blurringTransitionController.value);

  double get _overlaySplashOpacityValue => blurringTransitionController.value;
  double get _infoOpacityValue => (1-blurringTransitionController.value*1.5).clamp(0.0,1.0);
  double get _infoSlideUpValue => (blurringTransitionController.status == AnimationStatus.forward ? 1 : -1) * blurringTransitionController.value * 30 ;
}
