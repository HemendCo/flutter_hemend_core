import 'package:rxdart/rxdart.dart';

import '../isolate_manager/isolation_core.dart';

typedef AsyncTask<T> = Future<T> Function();

//
// ─── ASYNC TASK QUEUE ────────────────────────────────────────────────────────
//
/// base class of async task queue
/// this class is used to manage async task queues
abstract class IAsyncTaskQueue {
  /// execute async task based on the mechanism of the task queue
  Future<T> execute<T>(AsyncTask<T> task);

  /// add task to the queue
  void addToQueue<T>(AsyncTask<T> task);

  /// remove task from the queue
  void removeFromQueue<T>(AsyncTask<T> task);

  /// clear tasks queue
  void clearQueue();
  int get queueLength;

  /// run all tasks in the queue and then return all of the values in an array
  Future<List<Object?>> drain();

  /// run all tasks in the queue but rather than returning all results together
  /// at end of queue, return each result separately when its ready
  Stream<Object?> drainStream();

  /// synchronized task queue will wait for a task to complete then run the next
  ///
  /// in this mode there are limited workers to prevent high memory usage
  ///
  /// this mode is useful for tasks that use huge amounts of resources
  ///
  /// you can pass [maxWorkers] to set the number of workers to use
  ///
  /// if [useIsolate] is true, then the task will be run in an isolate using
  /// compute method, this is useful when tasks that block the UI thread are
  factory IAsyncTaskQueue.SynchronizedTaskQueue({
    int maxWorkers = 1,
    bool useIsolate = false,
  }) =>
      SynchronizedTaskQueue(
        maxWorkers,
        useIsolate,
      );
}

/// synchronized task queue will wait for a task to complete then run the next
///
/// in this mode there are limited workers to prevent high memory usage
///
/// this mode is useful for tasks that use huge amounts of resources
///
/// you can pass [maxWorkers] to set the number of workers to use
///
/// if [useIsolate] is true, then the task will be run in an isolate using
/// compute method, this is useful when tasks that block the UI thread are
class SynchronizedTaskQueue implements IAsyncTaskQueue {
  final List<AsyncTask<Object?>> _queue = <AsyncTask<Object?>>[];
  int _workerCount = 0;

  /// max amount of workers available for the Queue runner
  final int maxWorkers;
  @override
  int get queueLength => _queue.length;

  /// if true, then the task will be run in an isolate using compute method,
  final bool useIsolate;
  SynchronizedTaskQueue(
    this.maxWorkers,
    this.useIsolate,
  ) : assert(maxWorkers > 0);

  /// run worker task in an isolate
  Future<T> _isolateRunner<T>(AsyncTask<T> task) async {
    final result = await IsolationCore.createIsolateForSingleTask(
      task: _worker,
      taskParams: task,
    );
    return result.singleActOnFinished(
      onDone: (data) => data,
      onError: (err, st) {
        throw err!;
      },
    );
  }

  /// the core of this mode,
  /// this is the worker that runs the tasks in the queue
  Future<T> _worker<T>(dynamic task) async {
    if (task is! AsyncTask<T>) {
      throw Exception('task is not of type AsyncTask');
    }

    while (_workerCount >= maxWorkers) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    _workerCount++;

    try {
      final taskResult = await task();
      _workerCount--;
      return taskResult;
    } catch (e) {
      _workerCount--;
      rethrow;
    }
  }

  @override
  void addToQueue<T>(AsyncTask<T> task) {
    _queue.add(task);
  }

  @override
  void clearQueue() {
    _queue.clear();
  }

  Stream<Object?> _streamWorker() async* {
    for (final task in List.from(_queue)) {
      if (_queue.contains(task)) {
        removeFromQueue(task);
        yield await execute(task);
      }
    }
  }

  /// will run all tasks and return their value when its ready
  ///
  /// it will be respectful to the [maxWorkers] limit and use all available
  /// slots to create streams
  ///
  /// uses RxDart to create multiple workers and merge them together
  ///
  /// **Limitations:** it's workers count will be limited to the workers count
  /// at start of the stream
  @override
  Stream<Object?> drainStream() {
    assert(maxWorkers - _workerCount >= 0);
    return Rx.merge(
      List.generate(maxWorkers - _workerCount, (index) => _streamWorker()),
    );
  }

  @override
  Future<List<Object?>> drain() async {
    final result = <Object?>[];
    await drainStream().forEach(result.add);
    return result;
  }

  @override
  Future<T> execute<T>(
    AsyncTask<T> task,
  ) async =>
      useIsolate ? _isolateRunner(task) : _worker(task);

  @override
  void removeFromQueue<T>(AsyncTask<T> task) {
    _queue.remove(task);
  }
}
