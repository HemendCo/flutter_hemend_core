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

  Iterable<TK> getMissingKeys(List<TK> possibleOptions) sync* {
    for (final option in possibleOptions) {
      if (!containsKey(option)) {
        yield option;
      }
    }
  }

  void breakOnMissingKey(List<TK> possibleOptions) {
    final missingItems = getMissingKeys(possibleOptions);
    if (missingItems.isNotEmpty) {
      throw ErrorHandler('''

Cannot find a required entries in map: $this
Missing keys: $missingItems''', {
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
