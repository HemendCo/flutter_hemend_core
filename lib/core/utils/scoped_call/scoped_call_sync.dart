class ScopedCallSync<T> {
  const ScopedCallSync({required this.generator});

  final T Function() generator;
  R call<R>(R Function(T) request) => request(generator());
}
