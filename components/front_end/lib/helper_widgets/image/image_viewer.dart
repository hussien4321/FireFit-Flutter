import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';

class ImagePreview extends StatelessWidget {
  final String imageUrl, heroTag, title;

  ImagePreview({this.imageUrl, this.heroTag, this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openImageViewer(context),
      child: Container(
        decoration: BoxDecoration(
            image: imageUrl == null
                ? null
                : DecorationImage(
                    image: CachedNetworkImageProvider(imageUrl),
                    fit: BoxFit.cover,
                  ),
            shape: BoxShape.circle,
            color: Colors.grey,
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 0),
                  blurRadius: 0,
                  spreadRadius: 3)
            ]),
      ),
    );
  }

  _openImageViewer(context) {
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) =>
            _ImageViewer(imageUrl, heroTag, title)));
  }
}

class _ImageViewer extends StatelessWidget {
  final String imageUrl, heroTag, title;

  _ImageViewer(this.imageUrl, this.heroTag, this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: Navigator.of(context).pop,
        ),
        title: Text(
          title,
          style: TextStyle(
            inherit: true,
            fontWeight: FontWeight.w300,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SizedBox.expand(
          child: Hero(
        tag: heroTag,
        child: ExtendedImageSlidePage(
          slideAxis: SlideAxis.both,
          slideType: SlideType.onlyImage,
          child: ExtendedImage(
            enableSlideOutPage: true,
            mode: ExtendedImageMode.Gesture,
            initGestureConfigHandler: (state) => GestureConfig(
              minScale: 1.0,
              animationMinScale: 0.8,
              maxScale: 3.0,
              animationMaxScale: 3.5,
              speed: 1.0,
              inertialSpeed: 100.0,
              initialScale: 1.0,
              inPageView: false,
            ),
            fit: BoxFit.contain,
            image: CachedNetworkImageProvider(
              imageUrl,
            ),
          ),
        ),
      )),
    );
  }
}
