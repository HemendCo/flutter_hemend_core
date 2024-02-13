import 'package:flutter/foundation.dart';

extension Caster<F> on F {
  T? to<T extends Object>([T? Function()? defaultValue]) => castTo<F, T>(
        this,
        defaultValue,
      );
  T forceTo<T extends Object>([T? Function()? defaultValue]) => castTo<F, T>(
        this,
        defaultValue,
      )!;
}

T? castTo<F, T extends Object>(F input, [T? Function()? defaultValue]) {
  if (input == null) {
    return defaultValue?.call();
  }
  if (input.runtimeType is T) {
    return input as T;
  }
  if (T == String) {
    return input.toString() as T;
  }
  if (T == int) {
    if (input is num) {
      return input.toInt() as T;
    }
    return (int.tryParse(input.toString()) ?? (defaultValue?.call())!) as T?;
  }
  if (T == double) {
    if (input is num) {
      return input.toDouble() as T;
    }
    return (double.tryParse(input.toString()) ?? (defaultValue?.call())!) as T?;
  }
  if (T == num) {
    if (input is num) {
      return input as T;
    }
    return (num.tryParse(input.toString()) ?? (defaultValue?.call())!) as T?;
  }
  if (T == Uri) {
    return (Uri.tryParse(input.toString()) ?? defaultValue?.call()) as T?;
  }
  if (T == DateTime) {
    if (input is String) {
      return (DateTime.tryParse(input) ?? defaultValue?.call()) as T?;
    } else if (input is num) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(input.toInt()) as T?;
      } on Object catch (_) {
        return defaultValue?.call();
      }
    }
  }
  if (kDebugMode) {
    print('caster cannot handle type [$T] returning default value');
  }
  return defaultValue?.call();
}

T castToForced<F, T extends Object>(F input, [T Function()? defaultValue]) {
  return castTo<F, T>(input, defaultValue) ?? (defaultValue?.call())!;
}
