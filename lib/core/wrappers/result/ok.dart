part of 'result.dart';

final class ResultOk<T, E extends Object> extends Result<T, E> with EquatableMixin {
  const ResultOk(this.ok);
  const ResultOk.ok({required this.ok});

  @override
  List<Object?> get props => [ok];

  @override
  Result<N, E> and<N>(Result<N, E> res) => res;

  @override
  Result<N, E> andThen<N>(Adapter<T, Result<N, E>> res) => res(ok);

  @override
  Null get err => null;

  @override
  T expect(String message) => ok;

  @override
  E expectErr(String message) {
    throw ResultExceptionWrapper(
      message: message,
      exception: ok,
    );
  }

  @override
  bool get isErr => false;

  @override
  bool get isOk => true;

  @override
  final T ok;

  @override
  Result<N, E> map<N>(Adapter<T, N> adapter) => Ok(adapter(ok));

  @override
  Result<T, N> mapErr<N extends Object>(Adapter<E, N> adapter) => Ok(ok);

  @override
  U mapOr<U>(
    Adapter<T, U> adapter, {
    required U defaultValue,
  }) =>
      adapter(ok);

  @override
  U mapOrElse<U>({
    required Adapter<E, U> onErr,
    required Adapter<T, U> onOk,
  }) =>
      onOk(ok);

  @override
  T unwrap() => ok;

  @override
  E unwrapErr() {
    throw ResultNullCheckFailure(
      name: 'unwrapErr',
      message: 'unwrapErr called on Ok result',
    );
  }

  @override
  E unwrapErrOr(E orElse) => orElse;

  @override
  T unwrapOr(T orElse) => ok;

  @override
  T unwrapOrElse(Adapter<E, T> orElse) => ok;
}
