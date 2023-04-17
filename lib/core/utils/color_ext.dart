import 'package:flutter/material.dart';

extension ColorExtension on Color {
  MaterialStateProperty<Color> get asMaterialProperty => MaterialStatePropertyAll(this);
}
