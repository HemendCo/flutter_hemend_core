part of 'result.dart';

final class ResultOk<T, E extends Object> extends Result<T, E> //
    with
        EquatableMixin {
  ResultOk(T ok) : ok = Some(ok);
  ResultOk.ok({required T ok}) : ok = Some(ok);

  @override
  List<Object?> get props => [ok];

  @override
  Result<N, E> and<N>(Result<N, E> res) => res;

  @override
  Result<N, E> andThen<N>(Adapter<T, Result<N, E>> res) => res(ok.value);

  @override
  None<E> get err => None<E>();

  @override
  T expect(String message) => ok.expect(message);

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
  final Some<T> ok;

  @override
  Result<N, E> map<N>(Adapter<T, N> adapter) => Ok(adapter(ok.value));

  @override
  Result<T, N> mapErr<N extends Object>(Adapter<E, N> adapter) => Ok(ok.value);

  @override
  U mapOr<U>(
    Adapter<T, U> adapter, {
    required U defaultValue,
  }) =>
      adapter(ok.value);

  @override
  U mapOrElse<U>({
    required Adapter<E, U> onErr,
    required Adapter<T, U> onOk,
  }) =>
      onOk(ok.value);

  @override
  T unwrap() => ok.value;

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
  T unwrapOr(T orElse) => ok.value;

  @override
  T unwrapOrElse(Adapter<E, T> orElse) => ok.value;

  @override
  FutureOr<void> onOk(Callback<T> callback) => callback(unwrap());
  @override
  FutureOr<void> onErr(Callback<E> callback) {}
}
