import 'package:flutter/material.dart';

mixin ListenableObject implements Listenable {
  final List<void Function()> _oneTimeCall = [];
  final List<void Function()> _listeners = [];
  void addOneTimeListener(void Function() listener) {
    _oneTimeCall.add(listener);
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void callThemAll() {
    for (final listener in _listeners) {
      listener();
    }
    for (final listener in _oneTimeCall) {
      listener();
    }
    _oneTimeCall.clear();
  }

  void removeAllListeners() {
    _listeners.clear();
    _oneTimeCall.clear();
  }
}
