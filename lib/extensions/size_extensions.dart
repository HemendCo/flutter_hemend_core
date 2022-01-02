import 'package:flutter/material.dart';

extension SizeConverters on num? {
  double percentOfWidth(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return (width * (this ?? 0) / 100);
  }

  double percentOfHeight(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return (height * (this ?? 0) / 100);
  }
}
