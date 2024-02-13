import 'package:flutter/material.dart';

import 'cache_provider.dart';
import 'cached_method_storage.dart';

extension Cached<P, T> on T Function(P) {
  T cached(String name, P params) => CachedMethodStorage.global.cachedRun(
        name,
        params,
        this,
      );
  T cachedOf(BuildContext context, String name, P params) => CacheProvider.of(
        context,
      ).cachedRun(
        name,
        params,
        this,
      );
}
