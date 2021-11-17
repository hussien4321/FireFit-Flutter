import 'package:flutter/material.dart';
import '../../../../helpers/helpers.dart';
import '../../../../front_end/helper_widgets.dart';

class StyleSelectorScreen  extends StatelessWidget {
  
  @override
  Widget build(BuildContext ctx) {
    return CustomScaffold(
      title: 'Select Style!',
      elevation: 0,
      appbarColor: Colors.transparent,
      body: SizedBox.expand(
        child: Column(
          children: _buildCategories(ctx)
        ),
      ),
    );
  }

  List<Widget> _buildCategories(BuildContext ctx) {
    List<Widget> categories = [];

    for(var style in ClothesStyles.values){
      categories.add(_buildCategory(ctx, Style(style)));
    }

    return categories;
  }

  Widget _buildCategory(BuildContext ctx, Style style){
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        child: StyleBanner(
          style: style,
          onTap: () => _saveCategory(ctx, style),
        ),
      )
    );
  }

  _saveCategory(BuildContext ctx, Style style) {
    Navigator.pop(ctx, style.name);
  }

}