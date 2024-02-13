extension TypeMatcher<T> on T {
  bool isIn(Iterable<T> items) => items.contains(this);
  bool isOneOf(Iterable<Type> types) => types.contains(runtimeType);
}
