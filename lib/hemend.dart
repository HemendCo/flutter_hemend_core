
import 'dart:ui';

// ignore: do_not_use_environment
const kTestMode = bool.fromEnvironment(
  'DEMO_MODE',
);

abstract class HemendToolkit {
  static Size? _viewPortSize;
  static Size? get viewPortSize => _viewPortSize;
  static void initTools({Size? viewPortSize}) {
    _viewPortSize = viewPortSize;
  }
}
