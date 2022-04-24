import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class SocketManager {
  ///Socket connection
  WebSocketChannel? _socket;
  void Function(String)? onConnect;
  void Function()? onDone;
  void Function(dynamic)? onError;
  void Function(String, Map<String, dynamic>)? onEmit;
  void Function(String)? onReceived;
  String _address = '';

  ///Set address of socket connection
  set address(String value) {
    _address = value;
    _socket = WebSocketChannel.connect(
      Uri.parse(value),
    );
    _socket!.stream.timeout(const Duration(hours: 5));
    _revokeAllListeners();
    (onConnect ?? (_) {})(value);
  }

  String get address => _address;

  //Dummy code
  void connect(String value) {
    address = value;
  }

  Future<void> waitForResult(
    String event, {
    Map<String, dynamic> initialData = const {},
    required void Function(dynamic) callBack,
  }) async {
    _once.addAll({event: callBack});

    await Future.doWhile(() async => _once.containsKey(event));
    return;
  }

  ///Sends Data to server through socket connection
  void emit(String key, [Map<String, dynamic> data = const {}]) {
    (onEmit ?? (_, __) {})(key, data);
    _socket?.sink.add(json.encode({'event': key, 'data': data}));
  }

  ///After changing address all events on socket will be lost
  ///it will revoke all of them
  void _revokeAllListeners() {
    _socket?.stream.listen(
      (value) => _eventReceived(value, _socket!),
      onError: (errorMessage) {
        (onError ?? (_) {})(errorMessage);
        //connect(address);
      },
      onDone: () {
        (onDone ?? () {})();
        //connect(address);
      },
    );
  }

  void _eventReceived(String data, WebSocketChannel sender) {
    (onReceived ?? (_) {})(data);
    final Map<String, dynamic> dataValue = jsonDecode(data);
    final String? event = dataValue['event'];
    final dynamic value = dataValue['data'];
    if (event != null) {
      _callListenersOn(event, value);
    }
  }

  ///Add listener to socket
  void addListener({
    required String event,
    required String key,
    required void Function(dynamic) listener,
  }) {
    ///If event where new it will be added to socket listeners
    if (!_listeners.keys.contains(event)) {
      _listeners.addAll({
        event: {key: listener}
      });
    }

    ///If event was not new and listener key where new
    ///it will be added to that events listeners
    else if (!_listeners[event]!.keys.contains(key)) {
      _listeners[event]!.addAll({key: listener});
    }

    ///If event was not new and listener key existed it will update the listener
    else {
      _listeners[event]![key] = listener;
    }
  }

  ///Call listeners of an event
  Future<void> _callListenersOn(String event, dynamic data) async {
    if (_listeners.keys.contains(event)) {
      for (final listener in (_listeners[event] ?? {}).values) {
        listener(data);
      }
    }
    if (_once.keys.contains(event)) {
      final listener = _once[event]!;
      _once.remove(event);
      listener(data);
    }
  }

  ///Remove listener with event and listener key
  bool removeListenerOn(String event, String key) {
    var result = false;
    if (!_listeners.keys.contains(event)) {
      result = false;
    } else if (!_listeners[event]!.keys.contains(key)) {
      result = false;
    } else {
      _listeners[event]!.remove(key);
      result = true;
    }
    return result;
  }

  final Map<String, void Function(dynamic)> _once = {};
  final Map<String, Map<String, void Function(dynamic)>> _listeners = {};

  Map<String, Map<String, void Function(dynamic)>> get listeners => _listeners;
}
