import 'package:flutter/material.dart';
import '../../../../middleware/middleware.dart';

class OutfitStats extends StatelessWidget {

  final Outfit outfit;
  final double size;

  OutfitStats({this.outfit, this.size = 12});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              outfit.averageRating.toString(),
              style: TextStyle(
                inherit: true,
                fontSize: size,
                color: Colors.white,
              ), 
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Image.asset(
                'assets/flame_white.png',
                width: size,
                height: size,
              )
            ),
            Text(
              outfit.ratingsCount.toString(),
              style: TextStyle(
                inherit: true,
                color: Colors.white,
                fontSize: size,
              ), 
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              outfit.commentsCount.toString(),
              style: TextStyle(
                inherit: true,
                color: Colors.white,
                fontSize: size
              ), 
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.comment,
                color: Colors.white,
                size: size,
              ),
            ),
          ],
        ),
      ],
    );
  }
}