import 'package:flutter/material.dart';

class SettingsHeader extends StatelessWidget {
  final String title;

  SettingsHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 8, top: 16, left: 8, right: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.subtitle2.copyWith(
              inherit: true,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
