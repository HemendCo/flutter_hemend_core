import 'dart:async';

class ScopedCallASync<T> {
  const ScopedCallASync({required this.generator});

  final FutureOr<T> Function() generator;
  Future<R> call<R>(FutureOr<R> Function(T) request) async {
    final generated = await generator();
    return request(generated);
  }
}
