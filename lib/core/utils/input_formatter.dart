import 'package:flutter/services.dart';

class NumberInputFormatter extends TextInputFormatter {
  NumberInputFormatter(
    this.minDoubleValue,
    this.maxDoubleValue, [
    this.validator,
  ]);
  final double minDoubleValue;
  final double maxDoubleValue;
  final bool Function(double value)? validator;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue,) {
    final doubleValue = double.tryParse(newValue.text);

    if (doubleValue == null) {
      if (newValue.text.isEmpty) {
        return newValue;
      }
      return oldValue;
    }
    if (doubleValue < minDoubleValue) {
      return newValue.copyWith(
        text: minDoubleValue.toString(),
        selection: TextSelection(
          baseOffset: 0,
          extentOffset: minDoubleValue.toString().length,
        ),
      );
    }
    if (doubleValue > maxDoubleValue) {
      return newValue.copyWith(
        text: maxDoubleValue.toString(),
        selection: TextSelection(
          baseOffset: 0,
          extentOffset: maxDoubleValue.toString().length,
        ),
      );
    }

    if (validator != null) {
      if (validator!(doubleValue)) {
        return newValue;
      }
      return oldValue;
    }
    return newValue;
  }
}

class IntNumberInputFormatter extends TextInputFormatter {
  IntNumberInputFormatter(
    this.minValue,
    this.maxValue, [
    this.validator,
  ]);
  final int? minValue;
  final int? maxValue;
  final bool Function(int value)? validator;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue,) {
    final doubleValue = int.tryParse(newValue.text);

    if (doubleValue == null) {
      if (newValue.text.isEmpty) {
        return newValue;
      }
      return oldValue;
    }
    if (minValue != null && doubleValue < minValue!) {
      return newValue.copyWith(
        text: minValue.toString(),
        selection: TextSelection(
          baseOffset: 0,
          extentOffset: minValue.toString().length,
        ),
      );
    }
    if (maxValue != null && doubleValue > maxValue!) {
      return newValue.copyWith(
        text: maxValue.toString(),
        selection: TextSelection(
          baseOffset: 0,
          extentOffset: maxValue.toString().length,
        ),
      );
    }

    if (validator != null) {
      if (validator!(doubleValue)) {
        return newValue;
      }
      return oldValue;
    }
    return newValue;
  }
}
