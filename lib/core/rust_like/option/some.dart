// ignore_for_file: prefer_const_constructors

part of 'option.dart';

final class Some<T> extends Option<T> {
  const Some(this.value);

  @override
  final T value;

  @override
  bool get isNone => false;

  @override
  bool get isSome => true;

  @override
  Result<T, UnwrapOnNull> ok() => Ok(value);

  @override
  Option<T> or(
    Option<T> orElse,
  ) =>
      this;

  @override
  Option<T> orElse(
    Lazy<Option<T>> orElse,
  ) =>
      this;

  @override
  Option<T> filter(
    bool Function(T) test,
  ) =>
      test(value) ? this : None<T>();

  @override
  Option<(T, N)> zip<N extends Object>(
    Option<N> other,
  ) =>
      switch (other) {
        final Some<N> other => Some((value, other.value)),
        _ => None<(T, N)>(),
      };

  @override
  T unwrap() => value;

  @override
  T unwrapOr(T defaultValue) => unwrap();

  @override
  T unwrapOrElse(Lazy<T> defaultLazy) => unwrap();

  @override
  Option<N> map<N>(
    Adapter<T, N> adapter,
  ) =>
      Some(adapter(unwrap()));

  /// Maps the option with an adapter and returns a default value.
  ///
  /// if the option is none.
  @override
  N mapOr<N>(
    Adapter<T, N> adapter, {
    required N defaultValue,
  }) =>
      switch (map<N>(adapter)) {
        final Some<N> value => value.value,
        None<N>() => defaultValue,
      };

  /// Maps the option with an adapter and
  /// lazily computes a default value if the option is none.
  @override
  N mapOrElse<N>(
    Adapter<T, N> adapter, {
    required Lazy<N> defaultLazy,
  }) =>
      switch (map<N>(adapter)) {
        final Some<N> value => value.value,
        None<N>() => defaultLazy(),
      };

  /// Returns the option if it's some, otherwise returns a default value.
  @override
  Option<N> and<N extends Object>(N res) => Some(res);

  /// Returns the option if it's some, otherwise lazily computes and returns a
  /// default value.
  @override
  Option<N> andThen<N extends Object>(
    Lazy<N> lazyRes,
  ) =>
      Some(lazyRes());

  /// Unwraps the option and returns the value, or throws an ExpectSomeOnNone
  /// error if the option is none.
  @override
  T expect(String message) => value;

  /// Throws an ExpectNoneOnSome error if the option is some,
  /// otherwise does nothing.
  @override
  void expectNone(
    String message,
  ) =>
      throw ExpectNoneOnSome(
        message: message,
      );

  /// Checks if the two options are equal.
  @override
  bool isEqualTo(
    Option<T> other,
  ) =>
      other is Some<T> && this.value == other.value;

  @override
  FutureOr<void> onOk(Callback<T> callback) => callback(unwrap());
}
