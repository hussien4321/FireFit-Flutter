import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';

class FitHeightBlurImage extends StatelessWidget {
  
  final String url;

  FitHeightBlurImage({this.url}); 
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SizedBox.expand(
          child: CachedNetworkImage(
            imageUrl: url,
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
            imageUrl: url,
            fit: BoxFit.fitHeight,
          ),
        ),
      ],
    );
  }
}