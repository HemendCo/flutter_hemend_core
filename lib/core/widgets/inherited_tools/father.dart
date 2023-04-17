import 'package:flutter/material.dart';

class Father<T> extends InheritedWidget {
  const Father({
    super.key,
    required super.child,
    required this.legacy,
  });

  final T legacy;

  static T? possibleLegacyOf<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Father<T>>()?.legacy;
  }

  static T legacyOf<T>(BuildContext context) {
    final value =
        context.dependOnInheritedWidgetOfExactType<Father<T>>()?.legacy;
    if (value == null) {
      throw Exception('cannot find any father for [$T] above this context');
    }
    return value;
  }

  @override
  bool updateShouldNotify(Father<T> oldWidget) {
    return true;
  }
}
