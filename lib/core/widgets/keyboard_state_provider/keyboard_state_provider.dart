import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/build_context_ext.dart';
import '../bloc/animated_bloc_builder.dart';

part 'keyboard_state.dart';
part 'keyboard_cubit.dart';
part 'keyboard_reactive_view.dart';

// ignore: avoid_implementing_value_types
class KeyboardStateProvider extends StatefulWidget implements ProxyWidget {
  const KeyboardStateProvider({super.key, required this.child});
  @override
  final Widget child;

  @override
  State<KeyboardStateProvider> createState() => _KeyboardStateProviderState();
}

class _KeyboardStateProviderState extends State<KeyboardStateProvider> {
  final controller = KeyboardCubit._();

  @override
  Widget build(BuildContext context) {
    controller._updateKeyboardState(context.isKeyboardOn);
    return BlocProvider<KeyboardCubit>.value(
      value: controller,
      child: widget.child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<KeyboardCubit>(
      'controller',
      controller,
    ));
  }
}
