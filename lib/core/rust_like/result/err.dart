part of 'result.dart';

final class ResultError<T, E extends Object> extends Result<T, E> //
    with
        EquatableMixin {
  ResultError(E err) : err = Some(err);
  ResultError.value({required E err}) : err = Some(err);

  @override
  List<Object?> get props => [err];

  @override
  Result<N, E> and<N>(Result<N, E> res) => Err(err.value);

  @override
  Result<N, E> andThen<N>(Adapter<T, Result<N, E>> res) => Err(err.value);

  @override
  final Some<E> err;

  @override
  T expect(String message) {
    throw ResultExceptionWrapper(
      message: message,
      exception: err,
    );
  }

  @override
  E expectErr(String message) => err.expect(message);

  @override
  bool get isErr => true;

  @override
  bool get isOk => false;

  @override
  Result<N, E> map<N>(Adapter<T, N> adapter) => Err(err.value);

  @override
  Result<T, N> mapErr<N extends Object>(
    Adapter<E, N> adapter,
  ) =>
      Err(adapter(err.value));

  @override
  U mapOr<U>(Adapter<T, U> adapter, {required U defaultValue}) => defaultValue;

  @override
  U mapOrElse<U>({
    required Adapter<E, U> onErr,
    required Adapter<T, U> onOk,
  }) =>
      onErr(err.value);

  @override
  None<T> get ok => None<T>();

  @override
  T unwrap() {
    throw ResultNullCheckFailure(
      name: 'unwrap',
      message: 'unwrap called on Err result',
    );
  }

  @override
  E unwrapErr() => err.unwrap();

  @override
  E unwrapErrOr(E orElse) => err.unwrapOr(orElse);

  @override
  T unwrapOr(T orElse) => orElse;

  @override
  T unwrapOrElse(Adapter<E, T> orElse) => orElse(err.value);
}
