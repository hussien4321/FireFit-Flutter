import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  
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
            _searchTerms(),
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

  //ADD DIALOGS FOR TERMS
  Widget _searchTerms(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Material(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.orangeAccent,
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
                      text: 'All',//DESIGN UI FOR STYLES (WHEEL??)
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

  //LINK TO OUTFIT OBJECT
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Center(//MAKE MIRROR OUTLINE WITH ASPECT RATIO INTO NEW WIDGET!!
                    child: Container(
                      decoration: BoxDecoration(
                        border: BorderDirectional(
                          bottom: BorderSide(width: thickness, color: Colors.grey[600]),
                          start: BorderSide(width: thickness, color: Colors.grey[500]),
                          top: BorderSide(width: thickness, color: Colors.grey[350]),
                          end: BorderSide(width: thickness, color: Colors.grey[300]),
                        ),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, thickness),
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: thickness,
                            spreadRadius: -thickness/2
                          )
                        ],
                        color: Color.fromRGBO(204, 187, 187,1.0),
                      ),
                      child: GestureDetector(
                        onVerticalDragUpdate: (s) => _switchToNextImage(),
                        onTap: openDetailedImage,
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

  Widget _buildPicture(String imagePath) {
    return Opacity(
      opacity: currentImagePath == imagePath ? 1.0 : 0.0,
      child: SizedBox.expand(
        child: Hero(
          tag: '$imagePath',
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
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
      builder: (context) => FullScreenImage(imagePath: widget.imagePath)
    ));
  }

  //CREATE OBJECT TO STORE ALL OUTFIT DETAILS
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
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Hussien's O.O.T.D.",
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                  Icon(
                    FontAwesomeIcons.male,
                    color: Colors.grey,
                  ),
                  Text(
                    '23',
                    style: Theme.of(context).textTheme.title.apply(color: Colors.grey),
                  )
                ],
              ),
            ),
            Row(
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
                          text: 'Casual',
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
                        '4 ',
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
                      '200 ',
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
            )
          ],
        ),
      ),
    );
  }

  double get _blurValue => Tween<double>(
    begin: 0.0,
    end: maxBlurSigma
  ).lerp(blurringTransitionController.value);

  double get _overlaySplashOpacityValue => blurringTransitionController.value;
  double get _infoOpacityValue => 1-blurringTransitionController.value;
}

//SEPARATE INTO NEW SCREEN
class FullScreenImage extends StatelessWidget {
  
  String imagePath;

  FullScreenImage({this.imagePath});


  //MAKE STATELESS AND REMOVE APP STATUS BAR
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                child: SizedBox(//TODO: ADD MIRROR OUTLINE TO THIS IMAGE 
                  height: 400.0,
                  width: double.infinity,
                  child: Container(
                    child: Hero(
                      tag: '$imagePath',
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}