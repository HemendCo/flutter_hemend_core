import 'dart:async';

import '../../contracts/typedefs/typedefs.dart';
import 'scoped_call_async.dart';
import 'scoped_call_stream.dart';
import 'scoped_call_sync.dart';

R usingSync<T, R>(
  Lazy<T> generator,
  Adapter<T, R> request,
) =>
    ScopedCallSync(generator: generator).call(request);

Future<R> usingAsync<T, R>(
  AsyncLazy<T> generator,
  AsyncAdapter<T, R> request,
) =>
    ScopedCallASync(generator: generator).call(request);

Stream<R> usingStream<T, R>(
  AsyncLazy<T> generator,
  Stream<R> Function(T) request,
) =>
    ScopedCallStream(generator: generator).call(request);
