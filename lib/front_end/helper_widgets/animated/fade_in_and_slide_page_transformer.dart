import 'package:flutter/material.dart';
import 'package:transformer_page_view/transformer_page_view.dart';
import 'dart:math';

class FadeInAndSlidePageTransformer extends PageTransformer {
  FadeInAndSlidePageTransformer() : super(reverse: true);

  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position;
    if (position <= 0) {
      double fadePosition = max(-1 , position*3);
      return new Opacity(
        opacity: 1.0 + fadePosition,
        child: new Transform.translate(
          offset: new Offset(info.width * -position, info.height * position),
          child: new Transform.scale(
            scale: 1.0,
            child: child,
          ),
        ),
      );
    } else if (position <= 1) {
      double fadePosition = min(1 , position*3);
      return new Opacity(
        opacity: 1.0 - fadePosition,
        child: new Transform.translate(
          offset: new Offset(info.width * -position, info.height * position),
          child: new Transform.scale(
            scale: 1.0,
            child: child,
          ),
        ),
      );
    }
    return child;
  }
}
