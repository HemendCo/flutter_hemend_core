import 'dart:math';

import 'package:hemend/io/socket/socket_manager.dart';

///**links object to socket**
///
///set [socketClient] before anything
///
///to setup the socket connection you need to use [plugItIn] e.g use it in constructor
///
///event name can be changed by setting [event]
///
///[listenerKey] is not required its there to set the listener's key for socket manager
///
///[emit] can be used to send data to socket with [_event] name
///
///finally you may use [unplug] to detach object from socket
mixin LiveWire implements ILiveWire {
  ///Event name on the socket side
  String _event = '';

  ///Changes event's name
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
  ///
  ///if you set [invokeAtConnect] false you may need to call [emit] manually
  void plugItIn(String event, String? key,
      [Map<String, dynamic>? invokeData = const {}]) {
    socketClient.removeListenerOn(_event, _listenerKey);
    _event = event;
    final randomValue = Random.secure().nextInt(5555555);
    _listenerKey = "${key ?? '_'}$randomValue";
    socketClient.addListener(
        event: event, key: _listenerKey, listener: updateFromMap);
    if (invokeData != null) {
      emit(invokeData);
    }
  }

  ///Disconnect object from socket
  bool unplug() {
    return socketClient.removeListenerOn(_event, _listenerKey);
  }

  ///Sends data into socket with this event
  void emit([Map<String, dynamic> data = const {}]) {
    socketClient.emit(_event, data);
  }
}

abstract class ILiveWire {
  ///the socket client that this object's event should attach to
  final SocketManager socketClient = SocketManager();

  ///emits data into [socketClient] on this [LiveWire]
  void emit([Map<String, dynamic> data]);

  ///disconnects live wire from [socketClient]
  bool unplug();

  ///connects live wire to the [socketClient]
  void plugItIn(String event, String? key, [Map<String, dynamic>? invokeData]);

  ///Update value from map comes from socket
  void updateFromMap(dynamic data);
}
