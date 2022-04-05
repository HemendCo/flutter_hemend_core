library hemend.variables;

///creates a variable that invokes its listeners on change
class ListenableVar<T> {
  ///creates a variable that invokes its listeners on change
  ListenableVar(T value) : _value = value;

  ///closing all listeners
  void dispose() {
    _listeners.clear();
  }

  ///Holds value
  T _value;

  ///Get value of variable
  T get value => _value;

  ///Set value of variable
  set value(T value) {
    _value = value;
    invokeListeners();
  }

  ///Get value of variable
  T call() => _value;

  ///Invoke All Listeners
  Future<void> invokeListeners() async {
    for (final listener in _listeners) {
      listener(_value);
    }
  }

  ///Listeners
  final List<void Function(T)> _listeners = [];

  ///Add listener to variable
  void addListener(void Function(T) p0) {
    _listeners.add(p0);
  }

  ///remove a listener
  void removeListener(void Function(T) p0) {
    _listeners.remove(p0);
  }

  void removeAllListeners() {
    _listeners.clear();
  }
}

class ListenableVarLazy<T> {
  ///creates a variable that invokes its listeners on change
  ListenableVarLazy(T value) : _value = value;

  ///closing all listeners
  void dispose() {
    _listeners.clear();
  }

  ///Holds value
  T _value;

  ///Get value of variable
  T get value => _value;

  ///Set value of variable
  set value(T value) {
    final temp = _value;
    _value = value;
    invokeListeners(temp, _value);
  }

  ///Get value of variable
  T call() => _value;

  ///Invoke All Listeners
  Future<void> invokeListeners(T oldValue, T newValue) async {
    for (final listener in _listeners) {
      listener(oldValue, newValue);
    }
  }

  ///Listeners
  final List<void Function(T, T)> _listeners = [];

  ///Add listener to variable
  void addListener(void Function(T, T) p0) {
    _listeners.add(p0);
  }

  ///remove a listener
  void removeListener(void Function(T, T) p0) {
    _listeners.remove(p0);
  }

  void removeAllListeners() {
    _listeners.clear();
  }
}
