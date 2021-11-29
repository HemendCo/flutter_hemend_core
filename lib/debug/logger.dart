import 'dart:async';
import 'dart:developer' as dev show log, inspect;

String get currentTimeTag =>
    '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}';

extension Logger on dynamic {
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

  void inspect() {
    dev.inspect(this);
  }
}
