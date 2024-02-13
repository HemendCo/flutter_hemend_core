import '../../contracts/typedefs/typedefs.dart';

extension GroupByImpl<T> on List<T> {
  Map<K, List<T>> groupBy<K>(Adapter<T, K> selector) {
    final result = <K, List<T>>{};
    for (final i in this) {
      final key = selector(i);
      result[key] = [
        ...result[key] ?? [],
        i,
      ];
    }
    return result;
  }
}
