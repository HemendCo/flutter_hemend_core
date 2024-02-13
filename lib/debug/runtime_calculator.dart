import 'dart:async' show Future, FutureOr;
import 'dart:developer';

import 'developer_tools.dart';

typedef DurationAndValueCarrier<T> = DataPairValueCarrier<Duration, T>;

/// [RuntimeCalculator] is used to calculate the runtime of a given [Function].
class RuntimeCalculator {
  RuntimeCalculator() : stopwatch = Stopwatch();
  final Stopwatch stopwatch;

  /// calculates the runtime of a given [Function] that passed with function
  ///
  /// it can be used to calculate runtime of more than a single function
  /// if you set [resetTimer] to false, it will not reset the timer before
  /// tracking
  ///
  /// [runtimeName] can be used to provide a name for the runtime to print in
  /// log
  Future<DurationAndValueCarrier<T>> calculateFor<T>(
    FutureOr<T> Function() function, {
    bool resetTimer = true,
    String runtimeName = 'Unnamed runtime calculator',
  }) async {
    if (resetTimer) {
      stopwatch.reset();
    }
    stopwatch.start();
    final result = await function();
    stopwatch.stop();

    () {
      log(
        'took ${stopwatch.elapsed} to finish the method',
        name: runtimeName,
      );
    }.runInDebugMode();
    return DurationAndValueCarrier(duration: stopwatch.elapsed, result: result);
  }
}

class DataPairValueCarrier<L, R> {

  DataPairValueCarrier({required this.duration, required this.result});
  final L duration;
  final R result;
}
