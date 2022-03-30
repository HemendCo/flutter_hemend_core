library hemend;

import 'dart:ui';

abstract class HemendToolkit {
  static Size? _viewPortSize;
  static Size? get viewPortSize => _viewPortSize;
  static void initTools({required Size viewPortSize}) {
    _viewPortSize = viewPortSize;
  }
}
