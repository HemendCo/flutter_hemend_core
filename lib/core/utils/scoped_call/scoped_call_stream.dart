import 'dart:async';

class ScopedCallStream<T> {
  const ScopedCallStream({required this.generator});

  final FutureOr<T> Function() generator;
  Stream<R> call<R>(Stream<R> Function(T) request) async* {
    final handler = await generator();
    yield* request(handler);
  }
}
