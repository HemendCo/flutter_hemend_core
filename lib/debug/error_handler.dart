enum ErrorType {
  retryCountReached('function failed after some retry'),
  apiFail('api failed (response or code)'),
  socketError('socket failed (response or after retry)'),
  unknownError('Wtf just happened?'),
  notFound('tried to access something that was not found'),
  typeError('one or more type was incorrect'),
  localFileNotFound('local file is missing or cannot be reached'),
  variableError('variable error (type or nullCheck failed)'),
  algorithmFail(
    'thrown from algorithm validator possibly one or more validation failed',
  ),
  strategyFail('strategy failed possibly a rare issue accrued'),
  notImplementedYet('called method is not implemented yet');

  const ErrorType(this.info);
  final String info;
}

class ErrorHandler implements Exception {
  final String message;
  final Set<ErrorType> errorTypes;

  ErrorHandler(this.message, [this.errorTypes = const {}]);
  @override
  String toString() {
    final result = StringBuffer();
    result.writeln();
    result.writeln(
      '================================================================',
    );
    result.writeln('message : $message');
    if (errorTypes.isNotEmpty) {
      result.writeln('<=-Tags-=> ');
      for (final error in errorTypes) {
        result.writeln(error.info);
      }
    }
    result.writeln(
      '================================================================',
    );
    return result.toString();
  }
}
