import 'dart:async';

import '../../../object_controllers/data_snap_handler/data_snap_handler.dart';
import '../key_value_repository.dart';

typedef EnvironmentsTable = IKeyValueStorageRepository<dynamic, String>;
typedef Snap<T> = DataSnapHandler<T>;

typedef Adapter<I, O> = O Function(I);
typedef Callback<P> = FutureOr<void> Function(P);
typedef AsyncAdapter<I, O> = Future<O> Function(I);
