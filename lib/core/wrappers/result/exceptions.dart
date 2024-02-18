part of 'result.dart';

sealed class ResultException extends Error {}

final class ResultExceptionWrapper<E> extends ResultException {
  ResultExceptionWrapper({
    required this.message,
    required this.exception,
  });

  final E exception;
  final String message;
  @override
  String toString() {
    return '$message: $exception';
  }
}

final class ResultNullCheckFailure extends ResultException {
  ResultNullCheckFailure({
    required this.name,
    required this.message,
  });
  final String message;
  final String name;
  @override
  String toString() {
    return '''
$message.

`$name` is not accessible on this result please use pattern matching before
calling unsafe methods
''';
  }
}
