import 'dart:async';

import 'scoped_call_async.dart';
import 'scoped_call_stream.dart';
import 'scoped_call_sync.dart';

R usingSync<T, R>(
  T Function() generator,
  R Function(T) request,
) =>
    ScopedCallSync(generator: generator).call(request);

Future<R> usingAsync<T, R>(
  FutureOr<T> Function() generator,
  FutureOr<R> Function(T) request,
) =>
    ScopedCallASync(generator: generator).call(request);

Stream<R> usingStream<T, R>(
  FutureOr<T> Function() generator,
  Stream<R> Function(T) request,
) =>
    ScopedCallStream(generator: generator).call(request);
