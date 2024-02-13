abstract class IKeyValueStorageRepository<K, V extends Object> {
  V? getValue(
    K key,
  );
  Future<K> add(V value);
  V getValueOrDefault(
    K key, {
    required V defaultValue,
  }) =>
      getValue(key) ?? defaultValue;

  Future<void> setValue(K key, V value);

  /// Returns value if deleted and null if had no value
  Future<V?> delete(K key);

  V? operator [](K key) => getValue(key);
  Iterable<V> getWhere(
    bool Function(K key) tester,
  );
  // void operator []=(K key, V value) => setValue(key, value);
}
