import 'package:flutter/material.dart';

class AnimatedPictureFrame extends StatefulWidget {
  final List<String> images;
  final BoxFit fit;
  final Duration transitionDuration;
  final Duration displayDuration;
  final bool shuffleImages;

  AnimatedPictureFrame({
    this.images,
    this.fit,
    this.shuffleImages = false,
    this.transitionDuration = const Duration(seconds: 1),
    this.displayDuration = const Duration(seconds: 3),
  }) :assert(images != null && images.length >= 2, "Not enough images");
  
  @override
  _AnimatedPictureFrameState createState() => _AnimatedPictureFrameState();
}

class _AnimatedPictureFrameState extends State<AnimatedPictureFrame> with SingleTickerProviderStateMixin {
  List<String> _images;
  Animation<double> animation;
  AnimationController animationController;
  var _opacity = 0.0;
  var _counter = -1;
  String _currentImage;
  String _nextImage;

  @override
  void initState() {
    super.initState();

    _images= widget.images;

    if(widget.shuffleImages){
      _images.shuffle();
    }

    _currentImage = _images[0];
    _nextImage = _images[1];

    animationController = AnimationController(duration: widget.transitionDuration, vsync: this);

    animation = Tween<double>(begin: 0, end: 1).animate(animationController)
      ..addStatusListener((state) {
        _counter++;
        if (state == AnimationStatus.completed) {
          setState(() {
            _nextImage = _images[(_counter + 1) % _images.length];
          });
          Future.delayed(widget.displayDuration, () {
            animationController.reverse();
          });
        } else if (state == AnimationStatus.dismissed) {
          setState(() {
            _currentImage = _images[(_counter + 1) % _images.length];
          });
          Future.delayed(widget.displayDuration, () {
            animationController.forward();
          });
        }
      })
      ..addListener(() {
        setState(() {
          _opacity = animation.value;
        });
      });

    Future.delayed(widget.displayDuration, () {
      animationController.forward();
    });
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _buildImage(
          opacity: 1, 
          imageUrl: _currentImage,
        ),
        _buildImage(
          opacity:  1 - _opacity, 
          imageUrl: _nextImage,
        ),
      ],
    );
  }
  Widget _buildImage({double opacity, String imageUrl}) {
    return SizedBox.expand(
      child: Opacity(
        opacity: opacity,
        child: Image.asset(
          imageUrl,
          fit: widget.fit,
        ),
      ),
    );
  }
}
