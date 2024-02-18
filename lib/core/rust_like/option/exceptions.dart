part of 'option.dart';

sealed class OptionException extends Error {}

final class UnwrapOnNull extends OptionException {
  @override
  String toString() {
    return 'Called `unwrap` on null value';
  }
}

sealed class Expected extends OptionException {}

final class ExpectSomeOnNone extends Expected {
  ExpectSomeOnNone({required this.message});

  final String message;
  @override
  String toString() {
    return '$message: Expected to be non-null on null value';
  }
}

final class ExpectNoneOnSome extends Expected {
  ExpectNoneOnSome({required this.message});

  final String message;
  @override
  String toString() {
    return '$message: Expected to be non-null on null value';
  }
}
