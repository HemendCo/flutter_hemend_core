import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/animated_bloc_builder.dart';
import '../cubit/hidden_wrapper.dart';

class HiddenWrapper<T extends Widget> extends StatelessWidget
    implements
// ignore: avoid_implementing_value_types
        HiddenWrapperView<T> {
  const HiddenWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.transitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.switchInCurve = Curves.linear,
    this.switchOutCurve = Curves.linear,
    this.controller,
  });
  @override
  final Widget child;
  @override
  final Duration duration;
  @override
  final Widget Function(
    Widget child,
    Animation<double> animation,
  ) transitionBuilder;
  @override
  final Curve switchInCurve;
  @override
  final Curve switchOutCurve;

  @override
  final HiddenWrapperController<T>? controller;
  @override
  Widget build(BuildContext context) {
    return BlocProvider<HiddenWrapperController<T>>(
      create: (context) => controller ?? HiddenWrapperController<T>(),
      child: HiddenWrapperView<T>(
        controller: controller,
        duration: duration,
        switchInCurve: switchInCurve,
        switchOutCurve: switchOutCurve,
        transitionBuilder: transitionBuilder,
        child: child,
      ),
    );
  }
}

extension TransitionChain on AnimatedSwitcherTransitionBuilder {
  AnimatedSwitcherTransitionBuilder chainWith(
    AnimatedSwitcherTransitionBuilder next,
  ) {
    return (child, animation) => this(next(child, animation), animation);
  }
}

class HiddenWrapperView<T extends Widget> extends StatelessWidget
    implements
// ignore: avoid_implementing_value_types
        ProxyWidget {
  const HiddenWrapperView({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.transitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.switchInCurve = Curves.linear,
    this.switchOutCurve = Curves.linear,
    this.controller,
  });
  @override
  final Widget child;
  final Duration duration;
  final Widget Function(
    Widget child,
    Animation<double> animation,
  ) transitionBuilder;
  final Curve switchInCurve;
  final Curve switchOutCurve;
  final HiddenWrapperController<T>? controller;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => //
          AnimatedBlocBuilder<HiddenWrapperController<T>, bool>(
        bloc: controller,
        transitionBuilder: transitionBuilder,
        duration: duration,
        switchInCurve: switchInCurve,
        switchOutCurve: switchOutCurve,
        builder: (context, state) => state ? child : const SizedBox(),
      ),
    );
  }

  static AnimatedSwitcherTransitionBuilder slideTransitionBuilder(
    AxisDirection direction,
  ) {
    final Tween<Offset> tween;
    switch (direction) {
      case AxisDirection.up:
        tween = Tween(begin: const Offset(0, -1), end: Offset.zero);
      case AxisDirection.right:
        tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
      case AxisDirection.down:
        tween = Tween(begin: const Offset(0, 1), end: Offset.zero);
      case AxisDirection.left:
        tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
    }
    return (
      child,
      animation,
    ) =>
        SlideTransition(
          position: tween.animate(animation),
          child: child,
        );
  }

  static AnimatedSwitcherTransitionBuilder sizeTransitionBuilder(
    Axis axis, {
    double axisAlignment = 0,
  }) {
    return (
      child,
      animation,
    ) =>
        SizeTransition(
          axis: axis,
          sizeFactor: animation,
          axisAlignment: axisAlignment,
          child: child,
        );
  }

  static Widget sizeTransition(Widget child, Animation<double> animation) {
    // final slide = Tween(begin: const Offset(0, 1), end: Offset.zero);
    return SizeTransition(
      sizeFactor: animation,
      child: child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Duration>('duration', duration))
      ..add(
        ObjectFlagProperty<
            Widget Function(
              Widget child,
              Animation<double> animation,
            )>.has('transitionBuilder', transitionBuilder),
      )
      ..add(DiagnosticsProperty<Curve>('switchInCurve', switchInCurve))
      ..add(DiagnosticsProperty<Curve>('switchOutCurve', switchOutCurve))
      ..add(
        DiagnosticsProperty<HiddenWrapperController<T>?>(
          'controller',
          controller,
        ),
      );
  }
}
