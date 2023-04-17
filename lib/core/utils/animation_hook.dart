import 'package:flutter/widgets.dart';

class AnimationHook<T> extends Animation<T> {
  final T Function() getter;
  final AnimationStatus Function()? statusGenerator;
  AnimationHook({
    required this.getter,
    this.statusGenerator,
  });
  static AnimationHook<T> fromAnimation<T, S>(
      Animation<S> source, T Function(S) mapper) {
    final hook = AnimationHook<T>(
      getter: () => mapper(source.value),
      statusGenerator: () => source.status,
    );
    source.addListener(hook.hookListeners);
    source.addStatusListener(hook.hookStatusListeners);
    return hook;
  }

  void hookListeners() {
    for (final i in _listeners) {
      i();
    }
  }

  void hookStatusListeners(AnimationStatus status) {
    for (final i in _statusListeners) {
      i(status);
    }
  }

  final List<VoidCallback> _listeners = [];

  final List<AnimationStatusListener> _statusListeners = [];
  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void addStatusListener(AnimationStatusListener listener) =>
      _statusListeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  @override
  void removeStatusListener(AnimationStatusListener listener) =>
      _statusListeners.remove(listener);

  //TODO - fix so its correct
  @override
  AnimationStatus get status =>
      statusGenerator?.call() ?? AnimationStatus.forward;

  @override
  T get value => getter();
}
