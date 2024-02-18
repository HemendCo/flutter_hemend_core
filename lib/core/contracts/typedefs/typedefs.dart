import 'dart:async';

import '../../rust_like/result/result.dart';
import '../key_value_repository.dart';

typedef EnvironmentsTable = IKeyValueStorageRepository<dynamic, String>;
typedef Snap<T> = Result<T, Object>;

typedef Adapter<I, O> = O Function(I);
typedef AsyncAdapter<I, O> = FutureOr<O> Function(I);
typedef Callback<P> = FutureOr<void> Function(P);

typedef Lazy<T> = T Function();
typedef AsyncLazy<T> = FutureOr<T> Function();
