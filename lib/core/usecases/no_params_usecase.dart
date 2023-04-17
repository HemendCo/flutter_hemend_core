import 'usecase_sync.dart';

abstract class INoParamsUsecase<R> extends IUsecaseSync<void, R> {
  @override
  R invoke({void params});
}
