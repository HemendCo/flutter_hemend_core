import '../debug/error_handler.dart';

extension MapVerifier<TK, TV> on Map<TK, TV> {
  bool verifyLength(List<int> possibleOptions) {
    return possibleOptions.contains(length);
  }

  bool verifyKeys(List<TK> possibleOptions) {
    for (final option in possibleOptions) {
      if (!containsKey(option)) {
        return false;
      }
    }
    return true;
  }

  TK? getMissingKey(List<TK> possibleOptions) {
    for (final option in possibleOptions) {
      if (!containsKey(option)) {
        return option;
      }
    }
    return null;
  }

  void breakOnMissingKey(List<TK> possibleOptions) {
    final missingItem = getMissingKey(possibleOptions);
    if (missingItem != null) {
      throw ErrorHandler('''

Cannot find a required entry in map: $this
Missing key: $missingItem''', {
        ErrorType.variableError,
        ErrorType.notFound,
      });
    }
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
