import 'package:flutter/material.dart';
import 'dart:ui';

class ExploreOutfitsScreen extends StatefulWidget {
  @override
  _ExploreOutfitsScreenState createState() => _ExploreOutfitsScreenState();
}

class _ExploreOutfitsScreenState extends State<ExploreOutfitsScreen> {
  
  List<String> outfits = [
    'assets/outfit1.jpg',
    'assets/outfit2.jpg',
    'assets/outfit3.jpg',
    'assets/outfit4.jpg',
    'assets/outfit5.jpg',
    'assets/outfit6.jpg',
  ];

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
            Expanded(
              child: MagicMirror(
                imagePath: outfits[currentIndex],
                nextImagePath: outfits[nextIndex],
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
  }){
    double iconSize = largeIcon ? 30.0 : 24.0;
    double padding = largeIcon ? 8.0 : 6.0;
    return Container(
      width: iconSize + padding*2,
      height: iconSize + padding*2, 
      decoration: BoxDecoration(
        color: Colors.white,
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
        color: color,
        padding: EdgeInsets.all(padding),
        icon: Icon(icon),
        iconSize: iconSize,
        onPressed: onPressed,
      ),
    );
  }
}

class MagicMirror extends StatefulWidget {
  final String imagePath;
  final String nextImagePath;
  final double thickness;
  final VoidCallback onNextPicShown;

  MagicMirror({
    this.imagePath,
    this.nextImagePath,
    this.thickness = 6,
    this.onNextPicShown,
  }): assert(imagePath != null);

  @override
  _MagicMirrorState createState() => _MagicMirrorState();
}

class _MagicMirrorState extends State<MagicMirror> with SingleTickerProviderStateMixin {

  String currentImagePath;

  double thickness;
  AnimationController blurringTransitionController;
  
  final double maxBlurSigma = 10.0;

  @override
  void initState() {
    thickness = widget.thickness;
    currentImagePath = widget.imagePath;

    blurringTransitionController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..addListener(() => setState((){}))
    ..addStatusListener((status) {
      if(status == AnimationStatus.completed){
        blurringTransitionController.reverse();
        currentImagePath = (currentImagePath == widget.imagePath) ? widget.nextImagePath : widget.imagePath;
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
    if(oldWidget.imagePath != widget.imagePath){
      setState(() {
       currentImagePath = widget.imagePath; 
      });
    }
    super.didUpdateWidget(oldWidget);
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: BorderDirectional(
            bottom: BorderSide(width: thickness, color: Colors.grey[600]),
            start: BorderSide(width: thickness, color: Colors.grey[500]),
            top: BorderSide(width: thickness, color: Colors.grey[350]),
            end: BorderSide(width: thickness, color: Colors.grey[300]),
          ),
          boxShadow: [
            BoxShadow(
              offset: Offset(-thickness, thickness),
              color: Colors.black.withOpacity(0.6),
              blurRadius: thickness
            )
          ],
          color: Color.fromRGBO(204, 187, 187,1.0),
        ),
        child: GestureDetector(
          onTap: _switchToNextImage,
          child: AspectRatio(
            aspectRatio: 0.6,
            child: Stack(
              children: <Widget>[
                _buildPicture(widget.imagePath),
                _buildPicture(widget.nextImagePath),
                SizedBox.expand(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: _blurValue, sigmaY: _blurValue),
                    child: Container(
                      color: Color.fromRGBO(204, 187, 187, _overlaySplashOpacityValue),
                    )
                  ),
                ),
              ],
            )
          ),
        ),
      ),
    );
  }

  Widget _buildPicture(String imagePath) {
    return Opacity(
      opacity: currentImagePath == imagePath ? 1.0 : 0.0,
      child: SizedBox.expand(
        child: Image.asset(
          imagePath,
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

  double get _blurValue => Tween<double>(
    begin: 0.0,
    end: maxBlurSigma
  ).lerp(blurringTransitionController.value);

  double get _overlaySplashOpacityValue => blurringTransitionController.value;
}
