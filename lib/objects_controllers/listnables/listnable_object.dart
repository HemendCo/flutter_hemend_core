library hemend.object_controllers.listnables.listnable_object;

mixin ListnableObject {
  final List<void Function()> _oneTimeCall = [];
  final List<void Function()> _listners = [];
  void addOneTimeListner(void Function() listner) {
    _oneTimeCall.add(listner);
  }

  void addListener(void Function() listner) {
    _listners.add(listner);
  }

  void callThemAll() {
    for (var listner in _listners) {
      listner();
    }
    for (var listner in _oneTimeCall) {
      listner();
    }
    _oneTimeCall.clear();
  }

  void removeAllListners() {
    _listners.clear();
    _oneTimeCall.clear();
  }
}
