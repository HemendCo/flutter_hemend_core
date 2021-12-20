import 'dart:async';
import 'dart:developer' as dev show log, inspect;

String get currentTimeTag =>
    '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}';

///cache objects that are currently sent to debugger
final List<Object> _temp = [];

///use this only for debug purposes and don't use it in release version
extension Debugger on Object {
  /// **DO NOT USE IN RELEASE MODE**
  ///
  /// Emit a log event.
  ///
  /// This function was designed to map closely to the logging information
  /// collected by `package:logging`.
  ///
  /// - [message] is the log message
  /// - [time] (optional) is the timestamp
  /// - [sequenceNumber] (optional) is a monotonically increasing sequence number
  /// - [level] (optional) is the severity level (a value between 0 and 2000); see
  ///   the `package:logging` `Level` class for an overview of the possible values
  /// - [name] (optional) is the name of the source of the log message
  /// - [zone] (optional) the zone where the log was emitted
  /// - [error] (optional) an error object associated with this log event
  /// - [stackTrace] (optional) a stack trace associated with this log event
  @Deprecated("don't use log in release mode")
  log({
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String name = '',
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
  }) {
    assert(() {
      dev.log(toString(),
          level: level,
          name: name,
          zone: zone,
          error: error,
          stackTrace: stackTrace);
      return true;
    }());
  }

  /// **DO NOT USE IN RELEASE MODE**
  ///
  /// Send a reference to [object] to any attached debuggers.
  ///
  /// Debuggers may open an inspector on the object. Returns the argument.
  ///
  /// inspected object will be cached so you can see them if object lose all its references garbage collector will remove it and will be lost
  ///
  /// you may need to use [resetInspectCache] to clear cached objects
  @Deprecated("don't use inspector in release mode")
  void inspect() {
    assert(() {
      _temp.add(this);
      dev.inspect(_temp.last);
      return true;
    }());
  }

  ///Remove cache of inspector objects
  void resetInspectCache() {
    _temp.clear();
  }
}
