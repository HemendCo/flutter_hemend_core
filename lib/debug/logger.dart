// ignore_for_file: do_not_use_environment

import 'dart:async';
import 'dart:developer' as dev show inspect, log;

String get currentTimeTag => '''${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}''';

///cache objects that are currently sent to debugger
final List<Object> _temp = [];

/// limits the length of _temp array
///
/// override using `--dart-define=inspect_cache_size=<MaxSize>`
///
/// example: `flutter run --dart-define=inspect_cache_size=25`
const kMaxTempLength = int.fromEnvironment(
  'inspect_cache_size',
  defaultValue: 5,
);
void _addToTemp(Object object) {
  if (_temp.length > kMaxTempLength) {
    _temp.removeAt(0);
  }
  _temp.add(object);
}

///use this only for debug purposes and don't use it in release version
extension Debugger on Object {
  //TODO add max size for _temp items
  /// **DO NOT USE IN RELEASE MODE**
  ///
  /// **Use in Assertion or DevTools.runInDebugMode**
  ///
  /// Emit a log event.
  ///
  /// This function was designed to map closely to the logging information
  /// collected by `package:logging`.
  ///
  /// - [time] (optional) is the timestamp
  /// - [sequenceNumber] (optional) is a monotonically increasing sequence
  /// number
  /// - [level] (optional) is the severity level (a value between 0 and 2000);
  /// see
  ///   the `package:logging` `Level` class for an overview of the possible
  /// values
  /// - [name] (optional) is the name of the source of the log message
  /// - [zone] (optional) the zone where the log was emitted
  /// - [error] (optional) an error object associated with this log event
  /// - [stackTrace] (optional) a stack trace associated with this log event
  void log({
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String name = '',
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _addToTemp(this);
    dev.log(
      toString(),
      level: level,
      name: name,
      zone: zone,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void printToConsole() {
    print(this);
  }

  /// **DO NOT USE IN RELEASE MODE**
  ///
  /// **Use in Assertion or DevTools.runInDebugMode**
  ///
  /// Send a reference to [Object] to any attached debuggers.
  ///
  /// Debuggers may open an inspector on the object. Returns the argument.
  ///
  /// inspected object will be cached so you can see them if object lose all its
  /// references garbage collector will remove it and will be lost
  ///
  /// you may need to use [resetInspectCache] to clear cached objects
  @Deprecated('remove on production')
  void inspect() {
    _addToTemp(this);
    dev.inspect(_temp.last);
  }

  ///Remove cache of inspector objects

}

void resetInspectCache() {
  _temp.clear();
}
