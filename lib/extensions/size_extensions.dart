import 'package:flutter/material.dart';
import '../hemend.dart';

extension SizeConverters on num? {
  Size _getViewSize(BuildContext? context) {
    assert(context != null || HemendToolkit.viewPortSize != null);
    final viewportSize = HemendToolkit.viewPortSize ??
        MediaQuery.of(
          context!,
        ).size;
    return viewportSize;
  }

  double percentOfWidth([BuildContext? context]) {
    final width = _getViewSize(context).width;
    return width * (this ?? 0) / 100;
  }

  double percentOfHeight([BuildContext? context]) {
    final height = _getViewSize(context).height;
    return height * (this ?? 0) / 100;
  }
}
