extension CheckTypes on String {
  bool isChar() {
    if (length > 1) {
      return false;
    } else if (codeUnits[0] >= 65 && codeUnits[0] <= 122) {
      return true;
    } else {
      return false;
    }
  }
}

extension TypeConverter on String {
  double toDouble() {
    return double.parse(this);
  }

  int toInt() {
    return int.parse(this);
  }

  double? tryToDouble() {
    return double.tryParse(this);
  }

  int? tryToInt() {
    return int.tryParse(this);
  }
}
