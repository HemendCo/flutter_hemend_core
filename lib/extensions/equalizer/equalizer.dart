/// a mixin that will override the == operator and hashCode to
/// make it easier to handle
mixin EqualizerMixin implements _BaseEqualizer {
  @override
  bool operator ==(Object other) {
    ///checking if both of items are implementing the _BaseEqualizer
    if (other is! _BaseEqualizer) return false;

    ///checking if both are the same type
    if (runtimeType != other.runtimeType) return false;

    ///checking if both have same length of check items
    ///(actually it cannot be false cause each type may have same type
    ///but if used generative list it can handle that)
    if (equalCheckItems.length != other.equalCheckItems.length) return false;

    ///checking if both equalCheckItems have identical items
    for (var index = 0; index < equalCheckItems.length; index++) {
      if (equalCheckItems[index] != other.equalCheckItems[index]) return false;
    }

    return true;
  }

  @override
  int get hashCode => equalCheckItems.join().hashCode;

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return '\n=================================\n$runtimeType:\n--------------------------\n${equalCheckItems.join('\n--------------------------\n')}\n=================================';
  }
}

///base abstract class for equalizer
///
///all subclasses should overrider equalCheckItems
abstract class _BaseEqualizer {
  List<dynamic> get equalCheckItems;
  _BaseEqualizer._();
}
