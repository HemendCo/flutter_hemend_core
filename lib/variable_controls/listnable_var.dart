library hemend.variables;

///creates a variable that invokes its listners on change
class ListnableVar<T> {
  ///creates a variable that invokes its listners on change
  ListnableVar(T value) : _value = value;

  ///closing all listners
  void dispose() {
    _listners.clear();
  }

  ///Holds value
  T _value;

  ///Get value of variable
  T get value => _value;

  ///Set value of variable
  set value(T value) {
    _value = value;
    _invokeListners();
  }

  ///Get value of variable
  T call() => _value;

  ///Invoke All Listners
  Future<void> _invokeListners() async {
    for (final listner in _listners) {
      listner(_value);
    }
  }

  ///Listners
  final List<void Function(T)> _listners = [];

  ///Add listner to variable
  void addListner(void Function(T) p0) {
    _listners.add(p0);
  }
}
