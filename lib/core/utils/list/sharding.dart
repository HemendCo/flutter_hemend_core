extension ListExtension<T> on Iterable<T> {
  Iterable<Iterable<T>> shardsOfSize(int size) sync* {
    var current = this;
    while (current.isNotEmpty) {
      yield current.take(size);
      current = current.skip(size);
    }
  }
}
