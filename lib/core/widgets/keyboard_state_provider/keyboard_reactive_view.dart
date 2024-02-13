part of 'keyboard_state_provider.dart';

class KeyboardNotifiedView extends StatelessWidget {
  const KeyboardNotifiedView({
    super.key,
    required this.builder,
    this.controller,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration = const Duration(milliseconds: 300),
    this.transitionBuilder = defaultTransitionBuilder,
    this.layoutBuilder = AnimatedSwitcher.defaultLayoutBuilder,
    this.switchInCurve = Curves.linear,
    this.switchOutCurve = Curves.linear,
  });
  final KeyboardCubit? controller;
  final Duration duration;
  final Duration reverseDuration;
  final Widget Function(Widget, Animation<double>) transitionBuilder;
  final Widget? Function(KeyboardState state) builder;
  final Widget Function(Widget?, List<Widget>) layoutBuilder;
  final Curve switchInCurve;
  final Curve switchOutCurve;
  static Widget defaultTransitionBuilder(Widget child, Animation<double> animation) {
    return FadeScaleTransition(
      animation: animation,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBlocBuilder<KeyboardCubit, KeyboardState>(
      bloc: controller,
      duration: duration,
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      reverseDuration: reverseDuration,
      layoutBuilder: layoutBuilder,
      transitionBuilder: transitionBuilder,
      builder: (context, state) => builder(state) ?? const SizedBox(),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<KeyboardCubit?>('controller', controller));
  }
}
