library hemend.io.socket;

import 'dart:convert';
import 'dart:ffi';

import 'package:web_socket_channel/web_socket_channel.dart';

class SocketManager {
  ///Socket connection
  WebSocketChannel? _socket;
  void Function()? onConnect;
  void Function()? onDone;
  void Function()? onError;
  void Function(String)? onReceived;
  String _address = '';

  ///Set address of socket connection
  set address(String value) {
    _address = value;
    _socket = WebSocketChannel.connect(
      Uri.parse(value),
    );
    _socket!.stream.timeout(const Duration(hours: 5));
    _revokeAllListners();
    (onConnect ?? () {})();
  }

  String get address => _address;

  //Dummy code
  void connect(String value) {
    address = value;
  }

  Future<void> waitForResult(String event, void Function(dynamic) callBack,
      {Future<void> Function()? dummyTask}) async {
    _once.addAll({event: callBack});
    final task = dummyTask ?? () async {};
    await Future.doWhile(() async => _once.containsKey(event));

    return;
  }

  ///Sends Data to server through socket connection
  void emit(String key, Map data) {
    _socket?.sink.add(json.encode({'event': key, 'data': data}));
  }

  ///After changing address all events on socket will be lost it will revoke all of them
  void _revokeAllListners() {
    _socket?.stream.listen(
      (value) => _eventReceived(value, _socket!),
      onError: (test) {
        (onError ?? () {})();
        //connect(address);
      },
      onDone: () {
        (onDone ?? () {})();
        //connect(address);
      },
    );
  }

  void _eventReceived(String data, WebSocketChannel sender) {
    (onReceived ?? (_) {})(data + ' on ${sender.hashCode}');
    dynamic dataValue = jsonDecode(data);
    String? event = dataValue['event'];
    dynamic value = dataValue['data'];
    if (event != null) {
      _callListnersOn(event, value);
    }
  }

  ///Add listner to socket
  void addListner(
      {required String event,
      required String key,
      required void Function(dynamic) listner}) {
    ///If event where new it will be added to socket listners
    if (!_listners.keys.contains(event)) {
      _listners.addAll({
        event: {key: listner}
      });
    }

    ///If event was not new and listner key where new it will be added to that events listners
    else if (!_listners[event]!.keys.contains(key)) {
      _listners[event]!.addAll({key: listner});
    }

    ///If event was not new and listner key existed it will update the listner
    else {
      _listners[event]![key] = listner;
    }
  }

  ///Call listners of an event
  Future<void> _callListnersOn(String event, dynamic data) async {
    if (_listners.keys.contains(event)) {
      for (final listner in (_listners[event] ?? {}).values) {
        listner(data);
      }
    }
    if (_once.keys.contains(event)) {
      final listner = _once[event]!;
      _once.remove(event);
      listner(data);
    }
  }

  ///Remove listner with event and listner key
  bool removeListnerOn(String event, String key) {
    bool result = false;
    if (!_listners.keys.contains(event)) {
      result = false;
    } else if (!_listners[event]!.keys.contains(key)) {
      result = false;
    } else {
      _listners[event]!.remove(key);
      result = true;
    }
    return result;
  }

  final Map<String, void Function(dynamic)> _once = {};
  final Map<String, Map<String, void Function(dynamic)>> _listners = {};

  Map<String, Map<String, void Function(dynamic)>> get listners => _listners;
}
