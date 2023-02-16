import 'package:flutter/foundation.dart';

/// a mixin that will override the == operator and hashCode to
/// make it easier to handle
mixin EqualizerMixin implements _BaseEqualizer {
  @override
  bool operator ==(Object other) {
    ///checking if both of items are implementing the _BaseEqualizer
    if (other is! _BaseEqualizer) return false;

    ///checking if both are the same type
    if (runtimeType != other.runtimeType) return false;

    return listEquals(equalCheckItems, other.equalCheckItems);
  }

  @override
  int get hashCode => equalCheckItems.join().hashCode;

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return '\n=====\n$runtimeType:\n-----\n\t${equalCheckItems.join('\n-----\n\t')}\n=====';
  }
}

///base abstract class for equalizer
///
///all subclasses should overrider equalCheckItems
abstract class _BaseEqualizer {
  List<dynamic> get equalCheckItems;
  _BaseEqualizer._();
}
