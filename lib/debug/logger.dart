import 'dart:async';
import 'dart:developer' as dev show log, inspect;

String get currentTimeTag =>
    '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}';

///cache objects that are currently sent to debugger
final List<dynamic> _temp = [];

///use this only for debug purposes and dont use it in release version
extension Debugger on dynamic {
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
  log({
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String name = '',
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
  }) {
    dev.log(toString(),
        level: level,
        name: name,
        zone: zone,
        error: error,
        stackTrace: stackTrace);
  }

  /// Send a reference to [object] to any attached debuggers.
  ///
  /// Debuggers may open an inspector on the object. Returns the argument.
  ///
  /// Object will be cached you may need to use [resetInspectCache]
  @Deprecated('dont use inspector in release mode')
  void inspect() {
    _temp.add(this);
    dev.inspect(_temp.last);
  }

  ///Remove cache of inspector objects
  void resetInspectCache() {
    _temp.clear();
  }
}
