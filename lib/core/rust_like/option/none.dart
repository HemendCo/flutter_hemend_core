// ignore_for_file: prefer_const_constructors

part of 'option.dart';

final class None<T> extends Option<T> {
  const None();
  @override
  Null get value => null;
  @override
  Option<N> and<N>(N res) => None<N>();

  @override
  Option<N> andThen<N>(Lazy<N> lazyRes) => None<N>();

  @override
  T expect(String message) => throw ExpectSomeOnNone(
        message: message,
      );

  @override
  void expectNone(String message) {}

  @override
  Option<T> filter(bool Function(T p1) test) => None<T>();

  @override
  bool isEqualTo(Option<T> other) => other is None<T>;

  @override
  bool get isNone => true;

  @override
  bool get isSome => false;

  @override
  Option<N> map<N>(Adapter<T, N> adapter) => None<N>();

  @override
  N mapOr<N>(
    Adapter<T, N> adapter, {
    required N defaultValue,
  }) =>
      defaultValue;

  @override
  N mapOrElse<N>(
    Adapter<T, N> adapter, {
    required Lazy<N> defaultLazy,
  }) =>
      defaultLazy();

  @override
  Result<T, UnwrapOnNull> ok() => Err(UnwrapOnNull());

  @override
  Option<T> or(Option<T> orElse) => orElse;

  @override
  Option<T> orElse(Lazy<Option<T>> orElse) => orElse();

  @override
  T unwrap() {
    throw UnwrapOnNull();
  }

  @override
  T unwrapOr(T defaultValue) => defaultValue;

  @override
  T unwrapOrElse(Lazy<T> defaultLazy) => defaultLazy();

  @override
  Option<(T, N)> zip<N extends Object>(Option<N> other) => None<(T, N)>();

  @override
  FutureOr<void> onOk(Callback<T> callback) {}

  @override
  Iterable<T> get iter => Iterable.empty();

  @override
  Option<R> into<R extends Object>() => None();
}
