import 'dart:async';

import '../../wrappers/result/result.dart';
import '../key_value_repository.dart';

typedef EnvironmentsTable = IKeyValueStorageRepository<dynamic, String>;
typedef Snap<T> = Result<T, Object>;

typedef Adapter<I, O> = O Function(I);
typedef AsyncAdapter<I, O> = Future<O> Function(I);
typedef Callback<P> = FutureOr<void> Function(P);

typedef Option<T extends Object> = T?;
typedef Lazy<T> = T Function();
typedef AsyncLazy<T> = Future<T> Function();
