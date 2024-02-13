
import 'package:flutter/foundation.dart';

export 'package:hemend/debug/logger.dart';

abstract class DevTools {
  DevTools._();

  /// **can be used in final release**
  ///
  ///Runs given function only in debug mode
  static void runInDebugMode(void Function() task) {
    if (kDebugMode) {
      task();
    }
  }
}

extension DebugMode on void Function() {
  void runInDebugMode() {
    if (kDebugMode) {
      this();
    }
  }
}
