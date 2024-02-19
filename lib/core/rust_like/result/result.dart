import 'dart:async';

import 'package:equatable/equatable.dart';
import '../../contracts/typedefs/typedefs.dart';
import '../option/option.dart';

part 'exceptions.dart';
part 'ok.dart';
part 'err.dart';

/// Represents an error result.
typedef Err<T, E extends Object> = ResultError<T, E>;

/// Represents a successful result.
typedef Ok<T, E extends Object> = ResultOk<T, E>;

/// Lazy results can be used when you can validate parameters of the method
/// before the actual invocation
///
/// to get real value of results you can use `verify` method
typedef LazyResult<T, E extends Object> = Ok<Lazy<T>, E>;

/// Lazy results can be used when you can validate parameters of the method
/// before the actual invocation
///
/// to get real value of results you can use `verify` method
typedef LazyAsyncResult<T, E extends Object> = Ok<Future<T> Function(), E>;

/// A sealed class that encapsulates a result which can either be a success
/// ([Ok]) or an error ([Err]).
sealed class Result<T, E extends Object> {
  const Result();

  /// Returns `true` if the result is an [Ok] (success).
  bool get isOk;

  /// Returns `true` if the result is an [Err] (error).
  bool get isErr;

  /// Gets the error of type [E] if present; otherwise, returns `null`.
  Option<E> get err;

  /// Gets the success value of type [T] if present; otherwise, returns `null`.
  Option<T> get ok;

  /// Unwraps the success value,
  /// throwing [ResultNullCheckFailure] if the result is an [Err].
  T unwrap();

  /// Returns the success value if the result is an [Ok];
  /// otherwise, returns the provided [orElse] value.
  T unwrapOr(T orElse);

  /// Returns the success value if the result is an [Ok];
  /// otherwise, uses the [orElse] function to transform the error to a success
  /// value of type [T].
  T unwrapOrElse(Adapter<E, T> orElse);

  /// Unwraps the error value,
  /// throwing [ResultNullCheckFailure] if the result is an [Ok].
  E unwrapErr();

  /// Returns the error value if the result is an [Err];
  /// otherwise, returns the provided [orElse] value.
  E unwrapErrOr(E orElse);

  /// Applies the provided [adapter] function to the success value if the result
  /// is an [Ok]; otherwise, does nothing.
  Result<N, E> map<N extends Object?>(Adapter<T, N> adapter);

  /// Applies the provided [adapter] function to the error value if the result
  /// is an [Err]; otherwise, does nothing.
  Result<T, N> mapErr<N extends Object>(Adapter<E, N> adapter);

  /// On an [Ok] instance, maps the success value to type [U] using the provided
  /// [adapter] function.
  ///
  /// On an [Err] instance, returns the provided [defaultValue].
  U mapOr<U>(
    Adapter<T, U> adapter, {
    required U defaultValue,
  });

  /// On an [Ok] instance, maps the success value to type [U]
  /// using the [onOk] function.
  ///
  /// On an [Err] instance, maps the error value to type [U]
  /// using the [onErr] function.
  U mapOrElse<U>({
    required Adapter<E, U> onErr,
    required Adapter<T, U> onOk,
  });

  /// On an [Ok] instance, returns the provided [res] result.
  ///
  /// On an [Err] instance, returns the current [Err].
  Result<N, E> and<N>(Result<N, E> res);

  /// On an [Ok] instance, calls the provided [res]
  /// function with the success value and returns its result.
  ///
  /// On an [Err] instance, returns the current [Err].
  Result<N, E> andThen<N>(Adapter<T, Result<N, E>> res);

  /// On an [Ok] instance, returns [ok].
  ///
  /// On an [Err] instance, throws a [ResultExceptionWrapper]
  /// containing the error value.
  T expect(String message);

  /// On an [Ok] instance,
  /// throws a [ResultExceptionWrapper] containing the success value.
  ///
  /// On an [Err] instance, returns [err].
  E expectErr(String message);

  /// Calls the [callback] if the result is [Ok]
  /// otherwise does nothing
  FutureOr<void> onOk(Callback<T> callback);

  /// Calls the [callback] if the result is [Err]
  /// otherwise does nothing
  FutureOr<void> onErr(Callback<E> callback);

  /// Returns iterable containing value if result is [Ok]
  ///
  /// otherwise returns an empty iterable
  Iterable<T> get iter;

  /// calls given [action] inside a try catch
  ///
  /// returns `Ok<T,_>` if completed with no exception
  ///
  /// returns `Err<_,E>` if completed with exception
  static Result<T, E> handle<T, E extends Object>(T Function() action) {
    try {
      return Ok(action());
    } on E catch (e) {
      return Err(e);
    }
  }

  /// calls given async [action] inside a try catch
  ///
  /// returns `Ok<T,_>` if completed with no exception
  ///
  /// returns `Err<_,E>` if completed with exception
  static Future<Result<T, E>> handleAsync<T, E extends Object>(
    FutureOr<T> Function() action,
  ) async {
    try {
      return Ok(await action());
    } on E catch (e) {
      return Err(e);
    }
  }
}
