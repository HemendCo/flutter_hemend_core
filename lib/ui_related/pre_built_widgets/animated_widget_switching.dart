import 'package:flutter/material.dart';

class AnimatedWidgetSwitching extends StatefulWidget {
  final WidgetSwitchingController controller;
  final AnimatedWidget Function(Animation, Widget)? builder;
  const AnimatedWidgetSwitching({
    Key? key,
    required this.controller,
    this.builder,
  }) : super(key: key);

  @override
  // ignore: lines_longer_than_80_chars
  _AnimatedWidgetSwitchingState createState() => _AnimatedWidgetSwitchingState();
}

class _AnimatedWidgetSwitchingState extends State<AnimatedWidgetSwitching> {
  late final Animation<double> _animation;
  late final AnimatedWidget output;
  @override
  void initState() {
    _animation = Tween(
      begin: widget.controller.minimumAnimationValue,
      end: widget.controller.maximumAnimationValue,
    ).animate(
      CurvedAnimation(
        parent: widget.controller.animationController,
        curve: widget.controller.pushCurve,
        reverseCurve: widget.controller.popCurve,
      ),
    );
    widget.controller.animationController.value = 1;
    widget.controller.switchListener = () {
      if (mounted) setState(() {});
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (widget.builder ??
        (Animation<double> animation, child) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        })(_animation, widget.controller.currentWidget);
  }
}

class WidgetSwitchingController {
  final double minimumAnimationValue;
  final double maximumAnimationValue;
  final Curve popCurve;
  final Curve pushCurve;
  final AnimationController animationController;
  late Widget _currentWidget;
  Widget get currentWidget => _currentWidget;
  late void Function() switchListener;
  Future<void> pushAsync(Widget newChild) async {
    if (newChild.key == _currentWidget.key) {
      return;
    }
    await animationController.reverse();
    _currentWidget = newChild;
    switchListener();
    await animationController.forward();
  }

  WidgetSwitchingController({
    this.minimumAnimationValue = 0.1,
    this.maximumAnimationValue = 1,
    this.popCurve = Curves.easeOutQuad,
    this.pushCurve = Curves.easeInQuad,
    required Widget currentChild,
    required this.animationController,
  }) {
    _currentWidget = currentChild;
  }
}
