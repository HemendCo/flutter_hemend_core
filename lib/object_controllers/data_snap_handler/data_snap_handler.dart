import '../../extensions/equalizer/equalizer.dart';

enum SnapStatus {
  /// snap is carrying a data and is done
  done,

  /// snap is carrying an exception and is ended
  error,

  /// snap is not carrying any data and sender is still working
  progress,

  /// snap is carrying an incomplete peace of data and sender is still working
  progressWithData,

  ///snap is carrying a complete data but sender is still working
  singleSnap,
}

/// this class is used to carry data from unreliable source like network
///
/// can carry data, exception, progress and sender
///
/// at the same time only can have one of data or exception
///
/// but can carry a snap of data along with progress
///
/// the reason of creation of this class is that u can handle all type of
/// responses at the end
///
/// also its callable so u can use [instance()] instead of [singleAct]
class DataSnapHandler<T> with EqualizerMixin {
  ///an instance with [data] and no exception sender is done
  const DataSnapHandler.done({
    required this.data,
    required this.sender,
  })  : exception = null,
        progress = 1,
        status = SnapStatus.done;

  ///an instance with [exception] and no data sender has an error
  const DataSnapHandler.error({
    required this.exception,
    required this.sender,
  })  : data = null,
        progress = 0,
        status = SnapStatus.error;

  ///an instance with [progress] and maybe [data] and [sender] is still working
  const DataSnapHandler.loading({
    required this.progress,
    T? value,
    this.sender,
  })  : data = value,
        exception = null,
        status = SnapStatus.progress;

  ///an instance with [data] and [progress] set to -1 and [sender] is
  ///still working
  const DataSnapHandler.singleSnap({
    required this.data,
    this.sender,
  })  : progress = -1,
        exception = null,
        status = SnapStatus.singleSnap;

  /// will cast data type to [C]
  ///
  /// the reason is that some times data snap loses its type during some
  /// transmissions
  ///
  /// be careful with caster it will check the type of data before casting
  ///
  /// if data type is not [C] it will throw an exception if you are not passing
  /// [mapper]
  DataSnapHandler<C> castTo<C>({C Function(T)? mapper}) {
    if (data != null && data is! C) {
      if (mapper != null) {
        return DataSnapHandler<C>.done(
          data: mapper(data as T),
          sender: sender,
        );
      } else {
        throw Exception(
          'data type is not $C cannot cast ${data.runtimeType} to it',
        );
      }
    }
    switch (status) {
      case SnapStatus.done:
        return DataSnapHandler<C>.done(
          data: data as C,
          sender: sender,
        );

      case SnapStatus.error:
        return DataSnapHandler<C>.error(
          exception: exception,
          sender: sender,
        );
      case SnapStatus.singleSnap:
        return DataSnapHandler<C>.singleSnap(
          data: data as C,
          sender: sender,
        );

      // ignore: no_default_cases
      default:
        return DataSnapHandler<C>.loading(
          progress: progress,
          value: data as C?,
          sender: sender,
        );
    }
  }

  ///data value holder
  final T? data;

  ///exception value holder
  final Object? exception;

  ///sender that can be null
  final Object? sender;

  ///progress value holder
  final double progress;

  ///state of current snapshot
  final SnapStatus status;

  ///flag that checks if instance created with error
  bool get hasException => exception != null;

  ///flag that checks if there is any data
  bool get hasData => data != null;

  ///flag that checks if [sender] is still working
  bool get isLoading => status == SnapStatus.progress;

  ///flag that checks if [sender] is done working with [data] or [exception]
  bool get hasEnded => !isLoading;

  ///call the parameter with all information [data] [exception] [progress]
  R runForAll<R>(R Function(T?, Object?, double) worker) => worker(
        data,
        exception,
        progress,
      );

  ///this method will force you to handle all types of responses
  R call<R>({
    required R Function(T? data) onDone,
    required R Function(Object data, Object sender) onError,
    required R Function(double progress) onProgress,
    required R Function(T? data, double progress) onDataSnapshot,
  }) =>
      singleAct(
        onDone: onDone,
        onError: onError,
        onProgress: onProgress,
        onDataSnapshot: onDataSnapshot,
      );

  ///this method will force you to handle all types of responses
  R singleAct<R>({
    required R Function(T? data) onDone,
    required R Function(Object error, Object sender) onError,
    required R Function(double progress) onProgress,
    required R Function(T? data, double progress) onDataSnapshot,
  }) {
    switch (status) {
      case SnapStatus.done:
        return onDone(data);
      case SnapStatus.error:
        return onError(
          exception!,
          sender!,
        );
      case SnapStatus.progress:
        return onProgress(progress);
      case SnapStatus.progressWithData:
        return onDataSnapshot(data, progress);
      case SnapStatus.singleSnap:
        return onDataSnapshot(data, progress);
    }
  }

  R singleActOnFinished<R>({
    required R Function(T? data) onDone,
    required R Function(Object? error, Object? sender) onError,
  }) {
    if (status == SnapStatus.done) {
      return onDone(data);
    } else {
      return onError(exception, sender);
    }
  }

  @override
  List<dynamic> get equalCheckItems => [
        data,
        exception,
        sender,
        progress,
        status.name,
      ];
}
