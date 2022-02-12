import 'package:flutter/material.dart';

class AnimatedWidgetSwitching extends StatefulWidget {
  final WidgetSwitchingController controller;
  final AnimatedWidget Function(Animation, Widget)? builder;
  const AnimatedWidgetSwitching(
      {Key? key, required this.controller, this.builder})
      : super(key: key);

  @override
  _AnimatedWidgetSwitchingState createState() =>
      _AnimatedWidgetSwitchingState();
}

class _AnimatedWidgetSwitchingState extends State<AnimatedWidgetSwitching> {
  late final Animation<double> _animation;
  late final AnimatedWidget output;
  @override
  void initState() {
    _animation = Tween(
            begin: widget.controller.minmumAnimationValue,
            end: widget.controller.maximumAnimationValue)
        .animate(CurvedAnimation(
            parent: widget.controller.animationController,
            curve: widget.controller.pushCurve,
            reverseCurve: widget.controller.popCurve));
    widget.controller.animationController.value = 1;
    widget.controller.switchListner = () {
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
  final double minmumAnimationValue;
  final double maximumAnimationValue;
  final Curve popCurve;
  final Curve pushCurve;
  final AnimationController animationController;
  late Widget _currentWidget;
  Widget get currentWidget => _currentWidget;
  late void Function() switchListner;
  Future<void> pushAsync(Widget newChild) async {
    if (newChild.key == _currentWidget.key) {
      return;
    }
    await animationController.reverse();
    _currentWidget = newChild;
    switchListner();
    await animationController.forward();
  }

  WidgetSwitchingController(
      {this.minmumAnimationValue = 0.1,
      this.maximumAnimationValue = 1,
      this.popCurve = Curves.easeOutQuad,
      this.pushCurve = Curves.easeInQuad,
      required Widget currentChild,
      required this.animationController}) {
    _currentWidget = currentChild;
  }
}
