mixin ListenableObject {
  final List<void Function()> _oneTimeCall = [];
  final List<void Function()> _listeners = [];
  void addOneTimeListener(void Function() listener) {
    _oneTimeCall.add(listener);
  }

  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  void callThemAll() {
    for (var listener in _listeners) {
      listener();
    }
    for (var listener in _oneTimeCall) {
      listener();
    }
    _oneTimeCall.clear();
  }

  void removeAllListeners() {
    _listeners.clear();
    _oneTimeCall.clear();
  }
}
