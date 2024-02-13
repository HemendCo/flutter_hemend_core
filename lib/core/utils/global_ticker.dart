import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef AnimationControllerGenerator = //
    AnimationController Function(TickerProvider vsync);

extension Ticker on BuildContext {
  AnimationController buildAnimationController(
    AnimationControllerGenerator generator,
  ) {
    final ticker = findAncestorStateOfType<_GlobalTickerProviderState>();
    if (ticker == null) {
      throw Exception(
        '''
Cannot Find any GlobalTickerProvider on the given context
  - make sure to use GlobalTickerProvider in the entrypoint of application
  - make sure you are using it as parent to every widget in application
''',
      );
    }
    return ticker.buildAnimationController(generator);
  }

  AnimationController? maybeGetTicker(AnimationControllerGenerator generator) {
    return findAncestorStateOfType<_GlobalTickerProviderState>() //
        ?.buildAnimationController(generator);
  }
}

class GlobalTickerProvider extends StatefulWidget {
  const GlobalTickerProvider({super.key, required this.builder});
  final Widget Function(BuildContext context) builder;
  @override
  State<GlobalTickerProvider> createState() => _GlobalTickerProviderState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<Widget Function(BuildContext context)>.has(
        'builder',
        builder,
      ),
    );
  }
}

class _GlobalTickerProviderState extends State<GlobalTickerProvider> //
    with
        TickerProviderStateMixin {
  final List<AnimationController> _attachedControllers = [];
  AnimationController buildAnimationController(
    AnimationControllerGenerator generator,
  ) {
    final ctrl = generator(this);
    _attachedControllers.add(ctrl);
    return ctrl;
  }

  @override
  void dispose() {
    for (final c in _attachedControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
