import 'package:flutter/material.dart';

class BenefitOverview extends StatelessWidget {

  final IconData icon;
  final String title, description;

  BenefitOverview({
    this.icon,
    this.title,
    this.description,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 2,
                  offset: Offset(0, 2)
                ),
              ]
            ),
            child: Icon(
              icon,
              size: 48,
              color: Colors.blue,
            )
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.overline,
              textAlign: TextAlign.center,
            ),
          ),
          Flexible(
            child: Text(
              description,
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                color: Colors.grey
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ]
      ),
    );
  }
}