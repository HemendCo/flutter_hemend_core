library hemend.object_controllers.updaters.live_wire;

import 'dart:math';

import 'package:hemend/io/socket/socket_manager.dart';

mixin LiveWire implements _LiveWireBase {
  ///Event name on the socket side
  String _event = '';

  ///Change event name
  set event(String event) {
    socketClient.removeListnerOn(_event, _listnerKey);
    _event = event;
    socketClient.addListner(
        event: event, key: _listnerKey, listner: updateFromMap);
  }

  ///Listner key in app side (purpose: add more than one listner to an event without resuppling event which cannot be removed)
  String _listnerKey = '';

  ///Change Listner key
  set listnerKey(String key) {
    socketClient.removeListnerOn(_event, _listnerKey);
    final randomValue = Random.secure().nextInt(5555555);
    _listnerKey = "$key$randomValue";
    socketClient.addListner(
        event: _event, key: _listnerKey, listner: updateFromMap);
  }

  ///Connect object to socket with event name and listner key+random value
  void plugItIn(String event, String? key, {bool invokeAtConnect = true}) {
    socketClient.removeListnerOn(_event, _listnerKey);
    _event = event;
    final randomValue = Random.secure().nextInt(5555555);
    _listnerKey = "${key ?? '_'}$randomValue";
    socketClient.addListner(
        event: event, key: _listnerKey, listner: updateFromMap);
    if (invokeAtConnect) {
      emit(data: {});
    }
  }

  ///Disconnect object from socket
  bool unplug() {
    return socketClient.removeListnerOn(_event, _listnerKey);
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
