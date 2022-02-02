enum ErrorType {
  retryCountReached,
  apiFail,
  socketError,
  unknownError,
  notFound,
  typeError,
  localFileNotFound,
  variableError,
  algorithmFail,
  strategyFail,
  notImplementedYet,
}

extension ErrorInfo on ErrorType {
  String get info {
    String result = '$name : ';
    switch (this) {
      case ErrorType.retryCountReached:
        result += 'function failed after some retry';
        break;
      case ErrorType.apiFail:
        result += 'api failed (response or code)';
        break;
      case ErrorType.socketError:
        result += 'socket failed (response or after retry)';
        break;
      case ErrorType.unknownError:
        result += 'Wtf just happened?';
        break;
      case ErrorType.typeError:
        result += 'one or more type was incorrect';
        break;
      case ErrorType.localFileNotFound:
        result += 'local file is missing or cannot be reached';
        break;
      case ErrorType.variableError:
        result += 'variable error (type or nullCheck failed)';
        break;
      case ErrorType.algorithmFail:
        result +=
            'thrown from algorithm validator possibly one or more validation failed';
        break;
      case ErrorType.strategyFail:
        result += 'strategy failed possibly a rare issue accrued';
        break;
      case ErrorType.notImplementedYet:
        result += 'called method is not implemented yet';
        break;
      case ErrorType.notFound:
        result += 'tried to access something that was not found';
        break;
    }
    return result;
  }
}

class ErrorHandler implements Exception {
  final String message;
  final Set<ErrorType> errorTypes;

  ErrorHandler(this.message, [this.errorTypes = const {}]);
  @override
  String toString() {
    StringBuffer result = StringBuffer();
    result.writeln('');
    result.writeln(
        '================================================================');
    result.writeln('message : $message');
    if (errorTypes.isNotEmpty) {
      result.writeln('<=-Tags-=> ');
      for (final error in errorTypes) {
        result.writeln(error.info);
      }
    }
    result.writeln(
        '================================================================');
    return result.toString();
  }
}
