import 'dart:async';
import 'dart:isolate';

import '../../object_controllers/data_snap_handler/data_snap_handler.dart';

///parameters for single task isolate spawn
class SingleTaskIsolateParams<T, P> {
  SingleTaskIsolateParams({
    required this.sendPort,
    required this.task,
    required this.taskParams,
  });
  final SendPort sendPort;
  final FutureOr<T> Function(P) task;
  final P taskParams;
}

///parameters for stream
class StreamTaskIsolateParams<T, P> {
  StreamTaskIsolateParams({
    required this.sendPort,
    required this.task,
    required this.taskParams,
  });
  final SendPort sendPort;
  final Stream<DataSnapHandler<T>> Function(P) task;
  final P taskParams;
}

// ignore: avoid_classes_with_only_static_members
///isolation core which can spawn single task and stream task
abstract class IsolationCore {
  ///spawn an [Isolate] for singleShot async tasks
  ///
  ///receives a pointer to task and task params then spawn an isolate
  ///
  ///and run task inside it
  ///
  ///it has internal exception handling and will not break the main process
  ///
  ///return type is a [DataSnapHandler] with only Done or Error states
  static Future<DataSnapHandler<T>> createIsolateForSingleTask<T, P>({
    required FutureOr<T> Function(P) task,
    required P taskParams,
    String debugName = '',
  }) async {
    ///main port for exchanging data with isolate
    final receivePort = ReceivePort('$debugName-Port');

    ///mapping information to pass with spawn
    final isolateParams = SingleTaskIsolateParams<T, P>(
      sendPort: receivePort.sendPort,
      task: task,
      taskParams: taskParams,
    );

    ///spawning the isolate
    await Isolate.spawn<SingleTaskIsolateParams<T, P>>(
      _taskRunner,
      isolateParams,
      errorsAreFatal: false,
      debugName: '$debugName-Spawn',
    );

    try {
      ///awaiting for first result that has ended (Done or Error)
      ///
      ///then because the port will receive dynamic version of result it will
      ///cast it back to [DataSnapHandler]
      final finishedTasks = await receivePort.firstWhere(
        (element) => (element as DataSnapHandler).hasEnded,
      ) as DataSnapHandler;
      return finishedTasks.castTo<T>();
    } on Object catch (exception) {
      ///if there is an exception in the isolate or in casting part this will
      ///throw it
      return DataSnapHandler<T>.error(
        exception: exception,
        sender: {
          'name': 'Isolate Manager->createIsolateForSingleTask',
          'possible reasons': 'error in Receiving/Casting the DataSnapHandler from isolate',
          'exception': exception,
          'task': task,
          'taskParams': taskParams,
        },
      );
    }
  }

  ///spawn an [Isolate] for Stream async generator tasks
  ///
  ///receives a pointer to task and task params and listener for streaming data
  ///then spawn an isolate
  ///and
  ///run task inside it until task yield a [DataSnapHandler] with done or error
  ///state
  ///
  ///it has internal exception handling and will not break the main process
  ///
  ///yield type should be [DataSnapHandler] with all kind of states
  ///
  ///but as said before it will close the isolate on Done or Error state
  static Future<void> createIsolateForStream<T, P>({
    required Stream<DataSnapHandler<T>> Function(P) task,
    required P taskParams,
    required void Function(DataSnapHandler<T>) listener,
    String debugName = '',
  }) async {
    ///Main port for exchanging data with isolate
    ///and register listener to port and casting data to [DataSnapHandler]
    final receivePort = ReceivePort('$debugName-Port')
      ..listen((message) {
        late final DataSnapHandler<T> snap;
        if (message is DataSnapHandler) {
          snap = message.castTo<T>();
        } else {
          snap = DataSnapHandler<T>.error(
            exception: Exception(
              'Unexpected message type: ${message.runtimeType}',
            ),
            sender: {
              'name': 'Isolate Manager->createIsolateForStream',
              'reason': 'task should yield only [DataSnapHandler]',
              'task': task,
              'taskParams': taskParams,
            },
          );
        }
        listener(snap);
      });

    ///mapping information to pass with spawn
    final isolateParams = StreamTaskIsolateParams<T, P>(
      sendPort: receivePort.sendPort,
      task: task,
      taskParams: taskParams,
    );

    ///spawn the isolate main loop
    unawaited(
      Isolate.spawn(
        _streamTaskRunner<T, P>,
        isolateParams,
        errorsAreFatal: false,
        debugName: '$debugName-Spawn',
      ),
    );
  }

  ///main loop of the isolate for single tasks
  static Future<void> _taskRunner<T, P>(
    SingleTaskIsolateParams<T, P> params,
  ) async {
    late DataSnapHandler<T> result;
    try {
      result = DataSnapHandler.done(
        data: await params.task(params.taskParams),
        sender: {
          'name': 'Isolate Manager->_taskRunner',
          'task': params.task,
          'taskParams': params.taskParams,
        },
      );
    } on Object catch (exception, st) {
      result = DataSnapHandler.error(
        exception: exception,
        sender: st,
      );
    } finally {
      ///exiting the isolate after done a single shot
      Isolate.exit(params.sendPort, result);
    }
  }

  ///main loop of the isolate for stream tasks
  static Future<void> _streamTaskRunner<T, P>(
    StreamTaskIsolateParams<T, P> params,
  ) async {
    try {
      ///awaiting for each result from the task loop and will exit the isolate
      ///on Done or Error
      await for (final response in params.task(params.taskParams)) {
        switch (response.status) {
          case SnapStatus.done:
            Isolate.exit(params.sendPort, response);

          case SnapStatus.error:
            Isolate.exit(params.sendPort, response);

          // ignore: no_default_cases
          default:

            ///will pass data to stream but this time it will not close the
            ///isolate and will go on until receives Done or Error or on error
            params.sendPort.send(response);
        }
      }
    } on Object catch (exception) {
      Isolate.exit(
        params.sendPort,
        DataSnapHandler<T>.error(
          exception: exception,
          sender: 'Main Loop Of Stream Isolate',
        ),
      );
    }
  }
}
