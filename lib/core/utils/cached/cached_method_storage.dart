import 'package:hemend_logger/hemend_logger.dart';

class CachedMethodStorage with LogableObject {
  CachedMethodStorage(this._cacheStorage);
  static final CachedMethodStorage global = CachedMethodStorage({});
  void dispose() => clearAllCaches();
  final Map<int, Map<dynamic, dynamic>> _cacheStorage;
  void _save<P, T>(String name, P params, T result) {
    final l = getChild(name);
    final key = name.hashCode;
    if (_cacheStorage[key] == null) {
      _cacheStorage[key] = {};
      l.fine('cache was empty creating new storage for this scope');
    }
    if (_cacheStorage[key]![params] == null) {
      _cacheStorage[key]![params] = result;
      l.fine('saved into cache');
    }
  }

  T? _load<P, T>(
    String name,
    P params,
  ) =>
      _cacheStorage[name.hashCode]?[params] as T?;
  void clearCache(String name) {
    fine('removing cache storage for $name');
    _cacheStorage[name.hashCode]?.clear();
  }

  void clearAllCaches() {
    fine('cleaning cache storage');
    _cacheStorage.clear();
  }

  T cachedRun<P, T>(String name, P params, T Function(P) action) {
    final l = getChild(name);

    final cached = _load<P, T>(name, params);
    if (cached == null) {
      l.fine(
        '''result of this call with params($params) was not cached, will save for the next call''',
      );
      final result = action(params);
      _save<P, T>(name, params, result);
      return result;
    }
    l.fine('using cached answer for params($params)');
    return cached;
  }

  @override
  String get loggerName => 'CacheProvider';
}
