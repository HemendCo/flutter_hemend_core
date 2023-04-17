import 'usecase_sync.dart';

abstract class IUsecaseAsync<P, R> implements IUsecaseSync<P, Future<R>> {}
