extension ListExtension<T> on Iterable<T> {
  Iterable<T> get allButLast sync* {
    final lastIndex = length - 1;
    if (lastIndex <= 0) {
      return;
    }
    for (final (index, item) in indexed) {
      if (index < lastIndex) {
        yield item;
      }
    }
  }

  Iterable<T> get allButFirst sync* {
    for (final (index, item) in indexed) {
      if (index != 0) {
        yield item;
      }
    }
  }
}
