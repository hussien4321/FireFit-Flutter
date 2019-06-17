import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:front_end/helper_widgets.dart';

class UnderConstructionNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomBanner(
      icon: FontAwesomeIcons.tools,
      text: "This page is unfortunately still under construction, expect cool things soon!",
    );
  }
}