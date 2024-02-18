part of 'result.dart';

final class ResultError<T, E extends Object> extends Result<T, E> //
    with
        EquatableMixin {
  const ResultError(this.err);
  const ResultError.value({required this.err});

  @override
  List<Object?> get props => [err];

  @override
  Result<N, E> and<N>(Result<N, E> res) => Err(err);

  @override
  Result<N, E> andThen<N>(Adapter<T, Result<N, E>> res) => Err(err);

  @override
  final E err;

  @override
  T expect(String message) {
    throw ResultExceptionWrapper(
      message: message,
      exception: err,
    );
  }

  @override
  E expectErr(String message) => err;

  @override
  bool get isErr => true;

  @override
  bool get isOk => false;

  @override
  Result<N, E> map<N>(Adapter<T, N> adapter) => Err(err);

  @override
  Result<T, N> mapErr<N extends Object>(Adapter<E, N> adapter) => Err(adapter(err));

  @override
  U mapOr<U>(Adapter<T, U> adapter, {required U defaultValue}) => defaultValue;

  @override
  U mapOrElse<U>({
    required Adapter<E, U> onErr,
    required Adapter<T, U> onOk,
  }) =>
      onErr(err);

  @override
  Null get ok => null;

  @override
  T unwrap() {
    throw ResultNullCheckFailure(
      name: 'unwrap',
      message: 'unwrap called on Err result',
    );
  }

  @override
  E unwrapErr() => err;

  @override
  E unwrapErrOr(E orElse) => err;

  @override
  T unwrapOr(T orElse) => orElse;

  @override
  T unwrapOrElse(Adapter<E, T> orElse) => orElse(err);
}
