// ignore_for_file: comment_references, lines_longer_than_80_chars

import 'dart:async';
import 'dart:developer' as dev show log, inspect;

String get currentTimeTag => '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}';

///cache objects that are currently sent to debugger
final List<Object> _temp = [];

///use this only for debug purposes and don't use it in release version
extension Debugger on Object {
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
  /// - [sequenceNumber] (optional) is a monotonically increasing sequence number
  /// - [level] (optional) is the severity level (a value between 0 and 2000); see
  ///   the `package:logging` `Level` class for an overview of the possible values
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
    _temp.add(this);
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
    // dev.log(this.toString(), level: level, name: name, zone: zone, error: error, stackTrace: stackTrace);
  }

  /// **DO NOT USE IN RELEASE MODE**
  ///
  /// **Use in Assertion or DevTools.runInDebugMode**
  ///
  /// Send a reference to [object] to any attached debuggers.
  ///
  /// Debuggers may open an inspector on the object. Returns the argument.
  ///
  /// inspected object will be cached so you can see them if object lose all its references garbage collector will remove it and will be lost
  ///
  /// you may need to use [resetInspectCache] to clear cached objects
  void inspect() {
    _temp.add(this);
    dev.inspect(_temp.last);
  }

  ///Remove cache of inspector objects

}

void resetInspectCache() {
  _temp.clear();
}
