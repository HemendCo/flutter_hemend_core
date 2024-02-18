import '../option/option.dart';
import 'result.dart';

extension LazyResultExt<T, E extends Object> //
    on LazyResult<T, E> {
  /// map LazyResult<T,E> where T is a [F Function()] to Result<F,E>
  Result<T, E> verify() => andThen(Result.handle);
}

extension LazyAsyncResultExt<T, E extends Object>
    //
    on LazyAsyncResult<T, E> {
  /// map LazyAsyncResult<T,E> where T is a [Future<F> Function()]
  /// to Future<Result<F,E>>
  Future<Result<T, E>> verify() => mapOrElse(
        onErr: (err) => Future.value(Err(err)),
        onOk: Result.handleAsync<T, E>,
      );
}

extension FoldResult<T extends Object, E extends Object> on Result<Option<T>, E> {
  Option<T> fold() => Option.wrap(
        ok?.value,
      );
}
