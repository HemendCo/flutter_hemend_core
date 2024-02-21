import '../core/rust_like/option/option.dart';

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

extension TypeConverterStringExt on String {
  Option<double> toDouble() {
    return Option.wrap(double.tryParse(this));
  }

  Option<int> toInt() {
    return Option.wrap(int.tryParse(this));
  }

  Option<num> toNum() {
    return Option.wrap(num.tryParse(this));
  }
}
