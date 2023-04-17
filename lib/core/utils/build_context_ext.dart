import 'package:flutter/material.dart';

extension BuildContextExt on BuildContext {
  Size get size => MediaQuery.of(this).size;
  bool get isKeyboardOn => MediaQuery.of(this).viewInsets.bottom > 0;
  void removeFocusIfKeyboardIsDead() {
    if (!isKeyboardOn) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  void killFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  double get width => size.width;
  double get height => size.height;
  double get statusBarHeight => MediaQuery.of(this).padding.top;
  double get bottomBarHeight => MediaQuery.of(this).padding.bottom;
  double get safeAreaHeight => height - statusBarHeight - bottomBarHeight;
  double get safeAreaWidth => width;

  double percentOfHeight(double percent) {
    return safeAreaHeight * percent;
  }

  double percentOfWidth(double percent) {
    return width * percent;
  }

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
