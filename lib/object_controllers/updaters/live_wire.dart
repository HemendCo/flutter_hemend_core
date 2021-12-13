import 'dart:math';

import 'package:hemend/io/socket/socket_manager.dart';

mixin LiveWire implements _LiveWireBase {
  ///Event name on the socket side
  String _event = '';

  ///Change event name
  set event(String event) {
    socketClient.removeListenerOn(_event, _listenerKey);
    _event = event;
    socketClient.addListener(
        event: event, key: _listenerKey, listener: updateFromMap);
  }

  ///Listener key in app side (purpose: add more than one listener to an event without resupplying event which cannot be removed)
  String _listenerKey = '';

  ///Change Listener key
  set listenerKey(String key) {
    socketClient.removeListenerOn(_event, _listenerKey);
    final randomValue = Random.secure().nextInt(5555555);
    _listenerKey = "$key$randomValue";
    socketClient.addListener(
        event: _event, key: _listenerKey, listener: updateFromMap);
  }

  ///Connect object to socket with event name and listener key+random value
  void plugItIn(String event, String? key, {bool invokeAtConnect = true}) {
    socketClient.removeListenerOn(_event, _listenerKey);
    _event = event;
    final randomValue = Random.secure().nextInt(5555555);
    _listenerKey = "${key ?? '_'}$randomValue";
    socketClient.addListener(
        event: event, key: _listenerKey, listener: updateFromMap);
    if (invokeAtConnect) {
      emit(data: {});
    }
  }

  ///Disconnect object from socket
  bool unplug() {
    return socketClient.removeListenerOn(_event, _listenerKey);
  }

  ///Sends data into socket with this event
  void emit({Map data = const {}}) {
    socketClient.emit(_event, data);
  }
}

abstract class _LiveWireBase {
  final SocketManager socketClient = SocketManager();

  ///Update value from map comes from socket
  void updateFromMap(dynamic data);
}
