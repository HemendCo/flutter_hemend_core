import '../debug/error_handler.dart';

extension ListVerifications<T> on Iterable<T> {
  bool verifyLength(List<int> possibleOptions) {
    return possibleOptions.contains(length);
  }

  void breakOnLengthMissMatch(List<int> possibleOptions) {
    final lengthCheck = verifyLength(possibleOptions);
    if (!lengthCheck) {
      throw ErrorHandler(
        '''

Map length miss match: $length is not found in $possibleOptions''',
        {
          ErrorType.variableError,
          ErrorType.notFound,
        },
      );
    }
  }
}
