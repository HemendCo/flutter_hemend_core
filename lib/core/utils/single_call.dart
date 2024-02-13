class SingleCall<T> {
  SingleCall(
    this.method,
  ) : _isCalled = false;
  bool _isCalled;
  bool get isCalledAlready => _isCalled;
  final T Function() method;
  T? _result;
  T call() {
    if (!isCalledAlready) {
      _isCalled = true;
      _result = method();
    }
    if (_result is T) {
      return _result as T;
    }

    throw Exception("Unexpected behavior, result's type mismatch");
  }
}
