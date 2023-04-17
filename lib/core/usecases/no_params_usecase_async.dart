import 'usecase_async.dart';

abstract class INoParamsUsecaseAsync<R> extends IUsecaseAsync<void, R> {
  @override
  Future<R> invoke({void params});
}
