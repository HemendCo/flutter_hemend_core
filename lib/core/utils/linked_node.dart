// TODO Temporary

@Deprecated('Unstable API')
class LinkedNode<T> {
  LinkedNode._({
    LinkedNode<T>? previous,
    LinkedNode<T>? next,
    required this.currentValue,
    required this.totalLength,
    required this.nodeIndex,
  })  : _next = next,
        _previous = previous;

  factory LinkedNode.from(List<T> items) {
    if (items.isEmpty) {
      throw Exception('given list is empty');
    }
    final currentNode = LinkedNode._(
      currentValue: items.first,
      totalLength: items.length,
      nodeIndex: 0,
    );
    final rest = items.sublist(1);
    if (rest.isNotEmpty) {
      currentNode._iNext = LinkedNode._from(
        rest,
        previous: currentNode,
        index: 1,
        totalLength: items.length,
      );
    }

    return currentNode;
  }

  factory LinkedNode._from(
    List<T> items, {
    required LinkedNode<T> previous,
    required int index,
    required int totalLength,
  }) {
    if (items.isEmpty) {
      throw Exception('given list is empty');
    }
    final currentNode = LinkedNode._(
      currentValue: items.first,
      previous: previous,
      totalLength: totalLength,
      nodeIndex: index,
    );
    final rest = items.sublist(1);
    if (rest.isNotEmpty) {
      currentNode._iNext = LinkedNode._from(
        rest,
        previous: currentNode,
        totalLength: totalLength,
        index: index + 1,
      );
    }

    return currentNode;
  }

  LinkedNode<T>? _previous;

  LinkedNode<T>? get previous => _previous;

  // ignore: avoid_setters_without_getters
  set _iPrevious(LinkedNode<T>? value) {
    _previous = value;
  }

  LinkedNode<T>? _next;

  LinkedNode<T>? get next => _next;

  final int totalLength;
  final int nodeIndex;
  // ignore: avoid_setters_without_getters
  set _iNext(LinkedNode<T>? value) {
    _next = value;
  }

  final T currentValue;
  Iterable<LinkedNode<T>> get iterable sync* {
    var root = this;
    while (root.previous != null) {
      root = root.previous!;
    }
    while (root.next != null) {
      yield root;
      root = root.next!;
    }
    yield root;
  }

  @override
  // ignore: lines_longer_than_80_chars
  String toString() => 'LinkedNode(current: $currentValue,index: $nodeIndex,length: $totalLength)';
}
