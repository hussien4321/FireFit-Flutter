import 'package:flutter/material.dart';

class FadeInWidget extends StatefulWidget {

  final Widget child;
  final Duration duration;

  FadeInWidget({
    this.child,
    this.duration,
  }) : assert(child != null);

  @override
  _FadeInWidgetState createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget> with SingleTickerProviderStateMixin {
  
  AnimationController _fadeInController;

  Duration defaultFadeDuration = Duration(seconds: 1);

  @override
  void initState() {
    Duration duration = widget.duration ?? defaultFadeDuration;
    _fadeInController = new AnimationController(
      vsync: this,
      duration: duration
    )..addListener(() => setState((){}));
    _fadeInController.forward(from: 0.0);
    super.initState();
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeInController,
      child: widget.child,
    );
  }
}