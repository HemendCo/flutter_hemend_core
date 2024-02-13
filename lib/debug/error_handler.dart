enum ErrorType {
  retryCountReached(
    'function failed after some retry',
  ),
  apiFail(
    'api failed (response or code)',
  ),
  socketError(
    'socket failed (response or after retry)',
  ),
  unknownError(
    'Wtf just happened?',
  ),
  isNotInitializedYet(
    'the instance is not initialized yet try calling the initializer factory',
  ),
  notFound(
    'tried to access something that was not found',
  ),
  typeError(
    'one or more type was incorrect',
  ),
  localFileNotFound(
    'local file is missing or cannot be reached',
  ),
  variableError(
    'variable error (type or nullCheck failed)',
  ),
  algorithmFail(
    'thrown from algorithm validator possibly one or more validation failed',
  ),
  strategyFail(
    'strategy failed possibly a rare issue accrued',
  ),
  paramsError(
    'given params is not suitable for this method',
  ),
  notImplementedYet(
    'called method is not implemented yet',
  );

  const ErrorType(
    this.info,
  );
  final String info;
}

/// a class that extends Exception to provide a more detailed error message
/// and type of error
///
/// [ErrorType] is used to provide a more detailed error message
///
/// [errorTypes] is a [Set] that contains all the [ErrorType]s that are
/// cause of the error
class ErrorHandler implements Exception {

  const ErrorHandler(this.message, [this.errorTypes = const {}]);
  const ErrorHandler.isNotInitializedYet({
    required String objectName,
    String extraInformation = '',
  })  : message = '''the instance of $objectName is not initialized yet try calling the initializer factory
  $extraInformation''',
        errorTypes = const {
          ErrorType.isNotInitializedYet,
        };
  final String message;
  final Set<ErrorType> errorTypes;

  @override
  String toString() {
    final result = StringBuffer()
      ..writeln()
      ..writeln(
        '================================================================',
      )
      ..writeln('message : $message');
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
