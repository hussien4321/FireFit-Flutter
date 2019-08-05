import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselSliderWithIndicator extends StatefulWidget {

  final List<Widget> items;
  final double height;
  final double viewportFraction;
  final bool enableInfiniteScroll;
  final int initialPage;

  CarouselSliderWithIndicator({
    this.items,
    this.height,
    this.viewportFraction,
    this.enableInfiniteScroll,
    this.initialPage = 0,
  });

  @override
  _CarouselSliderWithIndicatorState createState() => _CarouselSliderWithIndicatorState();
}

class _CarouselSliderWithIndicatorState extends State<CarouselSliderWithIndicator> {
  int _current = 0;

  final double ICON_SIZE = 8;
  final double ICON_HORIZONTAL_MARGIN = 2;
  final double ICON_VERTICAL_MARGIN = 8;
  final Color SELECTED_ICON_COLOR = Colors.blue;
  final Color UNSELECTED_ICON_COLOR = Colors.black;
  
  PageController pageController;

  CarouselSlider cs;
  
  @override
  void initState() {
    super.initState();
    _current = widget.initialPage;
    pageController = new PageController(initialPage: widget.initialPage);
    cs = CarouselSlider(
      items: widget.items.map((item) => Padding(
        padding: EdgeInsets.only(bottom: ICON_SIZE + (ICON_VERTICAL_MARGIN)),
        child: item,
      )).toList(),
      height: widget.height,
      enableInfiniteScroll: widget.enableInfiniteScroll,
      enlargeCenterPage: true,
      viewportFraction: widget.viewportFraction,
      onPageChanged: (index) {
        setState(() {
          _current = pageController.page.round();
        });
      },
      initialPage: widget.initialPage,
    );
    pageController = cs.pageController;
  }

  @override
  Widget build(BuildContext context) {
    List<int> indexes = [];
    for(int i = 0; i<widget.items.length; i++){
      indexes.add(i);
    }



    return Stack(
      children: [
        cs,
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: indexes.map((index) {
              return Container(
                width: ICON_SIZE,
                height: ICON_SIZE,
                margin: EdgeInsets.only(left: ICON_HORIZONTAL_MARGIN, right: ICON_HORIZONTAL_MARGIN, top: ICON_VERTICAL_MARGIN),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: indexes.length<=1 ? Colors.transparent: ( _current == index ? SELECTED_ICON_COLOR : UNSELECTED_ICON_COLOR)
                )
              );
            }
            ).toList()
          )
        )
      ]
    );
  }

  bool get showIndicators => widget.items.length > 1;
}
