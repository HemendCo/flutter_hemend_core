import '../../contracts/typedefs/typedefs.dart';
import '../result/result.dart';

part 'exceptions.dart';

extension OptionImpl<T extends Object> on Option<T> {
  /// Checks if the option contains a value (some).
  /// Returns true if the option is some, false otherwise.
  bool get isSome => this is T;

  /// Checks if the option does not contain a value (none).
  /// Returns true if the option is none, false otherwise.
  bool get isNone => this == null;

  /// Converts the option into a Result.
  /// If the option is some, returns a Result.ok with the value.
  /// If the option is none, returns a Result.err with an UnwrapOnNull error.
  Result<T, UnwrapOnNull> ok() => Result.handle(unwrap);

  /// Returns the option if it's some,
  ///
  /// otherwise returns a default option.
  Option<T> or(
    Option<T> orElse,
  ) =>
      isSome ? this : orElse;

  /// Returns the option if it's some, otherwise
  ///
  /// lazily computes and returns a default option.
  Option<T> orElse(
    Lazy<Option<T>> orElse,
  ) =>
      isSome ? this : orElse();

  /// Filters the option based on a predicate.
  ///
  /// If the option is some and the predicate returns true, returns the option.
  ///
  /// Otherwise, returns none.
  Option<T> filter(
    bool Function(T) test,
  ) =>
      isSome && test(this!) ? this : null;

  /// Zips the option with another option.
  /// If both options are some, returns a new option with a pair of their values
  ///
  /// Otherwise, returns none.
  Option<(T, N)> zip<N extends Object>(
    Option<N> other,
  ) =>
      isSome && other.isSome ? (this!, other!) : null;

  /// Unwraps the option and returns the value.
  /// If the option is none, throws an UnwrapOnNull error.
  T unwrap() => isSome ? this! : throw UnwrapOnNull();

  /// Unwraps the option and returns the value, or
  /// a default value if the option is none.
  T unwrapOr(T defaultValue) => this ?? defaultValue;

  /// Unwraps the option and returns the value, or
  /// lazily computes and returns a default value if the option is none.
  T unwrapOrElse(Lazy<T> defaultLazy) => this ?? defaultLazy();

  /// Maps the option with an adapter.
  /// If the option is some, applies the adapter to the value and returns a
  /// new option.
  ///
  /// If the option is none, returns none.
  Option<N> map<N extends Object>(
    Adapter<T, N> adapter,
  ) =>
      isSome ? adapter(unwrap()) : null;

  /// Maps the option with an adapter and returns a default value.
  ///
  /// if the option is none.
  N mapOr<N>(
    Adapter<T, N> adapter, {
    required N defaultValue,
  }) =>
      map(adapter) ?? defaultValue;

  /// Maps the option with an adapter and
  /// lazily computes a default value if the option is none.
  N mapOrElse<N>(
    Adapter<T, N> adapter, {
    required Lazy<N> defaultLazy,
  }) =>
      map(adapter) ?? defaultLazy();

  /// Returns the option if it's some, otherwise returns a default value.
  Option<N> and<N extends Object>(N res) => isSome ? res : null;

  /// Returns the option if it's some, otherwise lazily computes and returns a
  /// default value.
  Option<N> andThen<N extends Object>(
    Lazy<N> lazyRes,
  ) =>
      isSome ? lazyRes() : null;

  /// Unwraps the option and returns the value, or throws an ExpectSomeOnNone
  /// error if the option is none.
  T expect(String message) => isSome
      ? this!
      : throw ExpectSomeOnNone(
          message: message,
        );

  /// Throws an ExpectNoneOnSome error if the option is some,
  /// otherwise does nothing.
  void expectNone(String message) => isNone
      ? null
      : throw ExpectNoneOnSome(
          message: message,
        );

  /// Checks if the two options are equal.
  bool isEqualTo(
    Option<T> other,
  ) =>
      isNone && other.isNone || isSome && other.isSome && this == other;
}
