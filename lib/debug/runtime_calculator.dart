import 'dart:async' show Future, FutureOr;
import 'dart:developer';

/// [RuntimeCalculator] is used to calculate the runtime of a given [Function].
class RuntimeCalculator {
  final Stopwatch stopwatch;
  RuntimeCalculator() : stopwatch = Stopwatch();

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

    log(
      'took ${stopwatch.elapsed} to finish the method',
      name: runtimeName,
    );
    return DurationAndValueCarrier(stopwatch.elapsed, result);
  }
}

class DurationAndValueCarrier<T> {
  final Duration duration;
  final T value;
  const DurationAndValueCarrier(this.duration, this.value);
}
