import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'cached_method_storage.dart';

class _CacheInheritance extends InheritedWidget {
  // ignore: public_member_api_docs
  const _CacheInheritance({
    required super.child,
    required this.storage,
  });
  // ignore: prefer_const_constructors

  final CachedMethodStorage storage;

  @override
  bool updateShouldNotify(_CacheInheritance oldWidget) {
    return true;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<CachedMethodStorage>(
        'storage',
        storage,
      ),
    );
  }
}

class CacheProvider extends StatefulWidget {
  const CacheProvider({
    super.key,
    required this.child,
  });
  final Widget child;
  @override
  State<CacheProvider> createState() => _CacheProviderState();

  static CachedMethodStorage? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_CacheInheritance>() //
        ?.storage;
  }

  static CachedMethodStorage of(BuildContext context) {
    final provider = //
        context.dependOnInheritedWidgetOfExactType<_CacheInheritance>();
    assert(
      provider != null,
      'Cannot find any cached scope provider over given context',
    );
    return provider!.storage;
  }
}

class _CacheProviderState extends State<CacheProvider> {
  final storage = CachedMethodStorage(
    {},
  );
  @override
  void dispose() {
    storage.clearAllCaches();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _CacheInheritance(
      storage: storage,
      child: widget.child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<CachedMethodStorage>('storage', storage),
    );
  }
}
