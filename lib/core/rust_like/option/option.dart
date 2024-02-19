import 'dart:async';

import '../../contracts/typedefs/typedefs.dart';
import '../result/result.dart';

part 'exceptions.dart';
part 'some.dart';
part 'none.dart';

sealed class Option<T> {
  const Option();
  factory Option.none() => None<T>();
  factory Option.some(T value) => Some(value);
  factory Option.wrap(T? value) => value == null ? None<T>() : Some(value);

  /// Checks if the option contains a value (some).
  /// Returns true if the option is some, false otherwise.
  bool get isSome;

  /// Checks if the option does not contain a value (none).
  /// Returns true if the option is none, false otherwise.
  bool get isNone;

  /// Converts the option into a Result.
  /// If the option is some, returns a Result.ok with the value.
  /// If the option is none, returns a Result.err with an UnwrapOnNull error.
  Result<T, UnwrapOnNull> ok();

  /// returns [T] if Some
  ///
  /// otherwise returns null
  T? get value;

  /// Returns the option if it's some,
  ///
  /// otherwise returns a default option.
  Option<T> or(
    Option<T> orElse,
  );

  /// Returns the option if it's some, otherwise
  ///
  /// lazily computes and returns a default option.
  Option<T> orElse(
    Lazy<Option<T>> orElse,
  );

  /// Filters the option based on a predicate.
  ///
  /// If the option is some and the predicate returns true, returns the option.
  ///
  /// Otherwise, returns none.
  Option<T> filter(
    bool Function(T) test,
  );

  /// Zips the option with another option.
  /// If both options are some, returns a new option with a pair of their values
  ///
  /// Otherwise, returns none.
  Option<(T, N)> zip<N extends Object>(
    Option<N> other,
  );

  /// Unwraps the option and returns the value.
  /// If the option is none, throws an UnwrapOnNull error.
  T unwrap();

  /// Unwraps the option and returns the value, or
  /// a default value if the option is none.
  T unwrapOr(T defaultValue);

  /// Unwraps the option and returns the value, or
  /// lazily computes and returns a default value if the option is none.
  T unwrapOrElse(Lazy<T> defaultLazy);

  /// Maps the option with an adapter.
  /// If the option is some, applies the adapter to the value and returns a
  /// new option.
  ///
  /// If the option is none, returns none.
  Option<N> map<N>(
    Adapter<T, N> adapter,
  );

  /// Maps the option with an adapter and returns a default value.
  ///
  /// if the option is none.
  N mapOr<N>(
    Adapter<T, N> adapter, {
    required N defaultValue,
  });

  /// Maps the option with an adapter and
  /// lazily computes a default value if the option is none.
  N mapOrElse<N>(
    Adapter<T, N> adapter, {
    required Lazy<N> defaultLazy,
  });

  /// Returns the option if it's some, otherwise returns a default value.
  Option<N> and<N>(N res);

  /// Returns the option if it's some, otherwise lazily computes and returns a
  /// default value.
  Option<N> andThen<N>(
    Lazy<N> lazyRes,
  );

  /// Unwraps the option and returns the value, or throws an ExpectSomeOnNone
  /// error if the option is none.
  T expect(String message);

  /// Throws an ExpectNoneOnSome error if the option is some,
  /// otherwise does nothing.
  void expectNone(String message);

  /// Checks if the two options are equal.
  bool isEqualTo(
    Option<T> other,
  );

  /// Calls the [callback] if the option is Some
  /// otherwise does nothing
  FutureOr<void> onOk(Callback<T> callback);

  /// Returns iterable containing value if is Some
  ///
  /// otherwise returns an empty iterable
  Iterable<T> get iter;
}
