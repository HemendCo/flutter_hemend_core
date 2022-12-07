import 'dart:async' //
    show
        Future,
        FutureOr,
        Zone,
        ZoneSpecification,
        runZonedGuarded;
import 'dart:convert' as converter //
    show
        jsonDecode,
        jsonEncode;
import 'dart:developer' as dev;
import 'dart:io' //
    show
        Platform;

import 'package:device_info_plus/device_info_plus.dart' as device_info //
    show
        DeviceInfoPlugin;
import 'package:dio/dio.dart' //
    show
        Dio,
        Options;
import 'package:flutter/foundation.dart' //
    show
        FlutterError,
        FlutterErrorDetails;
import 'package:flutter/material.dart' as material_lib //
    show
        runApp,
        Widget,
        WidgetsFlutterBinding,
        FlutterErrorDetails,
        Material,
        Container,
        ErrorWidget,
        Colors,
        Center,
        Text,
        TextStyle;
import 'package:package_info_plus/package_info_plus.dart' as package_info //
    show
        PackageInfo;
import 'package:shared_preferences/shared_preferences.dart' as storage //
    show
        SharedPreferences;

import '../build_environments/build_environments.dart';
import '../debug/developer_tools.dart';
import '../debug/error_handler.dart';
import '../generated_env.dart';
import '../object_controllers/data_snap_handler/data_snap_handler.dart' as snap;
import '../task_manager/async_queue/async_task_queue.dart';
import '../task_manager/isolate_manager/isolation_core.dart' as treads //
    show
        IsolationCore;

class CrashHandler {
  static const _kModuleName = 'Crashlytix';

  ///uses singleton pattern first u need to initialize it with registerer
  ///then you can use report methods
  ///
  ///there are 2 way to use crash reporter
  ///it can handle try catch by itself (it has a [call] method can be used like
  ///Crashlytics.instance(() => someMethod()))
  ///
  ///or you can use [tryThis] like
  ///Crashlytics.instance.tryThis(() => someMethod()))
  ///
  ///alternatively you can pass exception and stackTrace to [recordError] method
  ///or pass a map to [recordRawMap] to record it
  ///
  ///although you can pass [Map<String,dynamic>] with extraInfo parameter to
  ///[call] [tryThis] or [recordError] methods and attach extra info to report
  static CrashHandler get instance {
    if (_instance == null) {
      throw const ErrorHandler.isNotInitializedYet(
        objectName: 'Crashlytics',
        extraInformation: '''
<============================>
Crashlytics is not initialized 
you can initialize it by using
CrashHandler.register(
  //Params here,
);
<============================>
if you don't want to use Crashlytics check what method calling it
''',
      );
    }
    return _instance!;
  }

  static CrashHandler get I => instance;
  static CrashHandler? _instance;
  static T? registerAndRunZoned<T>(
    T Function() body, {
    bool useDefaultUri = true,
    Map<Object?, Object?>? zoneValues,
    ZoneSpecification? zoneSpecification,
    Uri? reportUri,
    void Function(Object exception, StackTrace stackTrace)? onCrash,
    Map<String, String>? reportHeaders,
    IAsyncTaskQueue? taskQueue,
    Map<String, dynamic>? extraInfo,
    List<String> cleanFromDeviceInfo = const [
      'systemFeatures',
    ],

    ///it is a placeholder for crashed widgets
    material_lib.Widget Function(material_lib.FlutterErrorDetails)? errorWidget,
  }) {
    _instance = CrashHandler.register(
      reportUri: reportUri,
      useDefaultUri: useDefaultUri,
      errorWidget: errorWidget,
      extraInfo: extraInfo,
      taskQueue: taskQueue,
      onCrash: onCrash,
      cleanFromDeviceInfo: cleanFromDeviceInfo,
      reportHeaders: reportHeaders,
    );

    return instance.runZoned(
      body,
      zoneValues: zoneValues,
      zoneSpecification: zoneSpecification,
    );
  }

  /// task queue for uploading reports
  final IAsyncTaskQueue _taskQueue;
  CrashHandler.register({
    Uri? reportUri,
    bool useDefaultUri = true,
    void Function(Object exception, StackTrace stackTrace)? onCrash,
    Map<String, String>? reportHeaders,
    Map<String, dynamic>? extraInfo,
    List<String> cleanFromDeviceInfo = const [
      'systemFeatures',
    ],
    IAsyncTaskQueue? taskQueue,

    ///it is a placeholder for crashed widgets
    material_lib.Widget Function(material_lib.FlutterErrorDetails)? errorWidget,
  })  : _extraInfo = extraInfo ?? {},
        _onCrash = onCrash,
        _taskQueue = taskQueue ??
            IAsyncTaskQueue.SynchronizedTaskQueue(
              maxWorkers: 4,
            ),
        reportUri = useDefaultUri && reportUri == null
            ? Uri.parse(
                $Environments.CONFIG_CRASHLYTIX_SERVER_ADDRESS,
              )
            : reportUri,
        _cleanFromDeviceInfo = cleanFromDeviceInfo,
        _reportHeaders = reportHeaders ?? {} {
    _reportHeaders.addAll({
      'secret': $Environments.CONFIG_CRASHLYTIX_APP_SECRET,
      'app_id': $Environments.CONFIG_CRASHLYTIX_APP_ID,
    });
    _extraInfo.addAll(BuildEnvironments.toMap());
    print(_reportHeaders);
    _instance = this;

    ///will replace (red in debug mode / grey in release mode)
    ///default error widget and will catch its error and report it
    material_lib.ErrorWidget.builder = (
      material_lib.FlutterErrorDetails details,
    ) {
      recordError(
        details.exception,
        details.stack ?? StackTrace.empty,
        {
          'fullErrorLog': details.toString(),
        },
      );
      return (errorWidget ??
          (_) => material_lib.Material(
                child: material_lib.Container(
                  color: material_lib.Colors.red,
                  child: const material_lib.Center(
                    child: material_lib.Text(
                      'found a bug inside this view.',
                      style: material_lib.TextStyle(
                        color: material_lib.Colors.white,
                      ),
                    ),
                  ),
                ),
              ))(details);
    };

    _internalLog(
      '$_kModuleName initialized',
    );
  }

  /// runs a method or function in a [runZonedGuarded]
  /// to catch any exception happens in it and report it
  /// it's main usecase is running the [material_lib.runApp] method
  R? runZoned<R>(
    R Function() body, {
    Map<Object?, Object?>? zoneValues,
    ZoneSpecification? zoneSpecification,
  }) {
    return runZonedGuarded(
      () {
        material_lib.WidgetsFlutterBinding.ensureInitialized();
        FlutterError.onError = (FlutterErrorDetails errorDetails) {
          recordError(
            errorDetails.exception,
            errorDetails.stack ?? StackTrace.current,
            {
              'fullErrorLog': errorDetails.toString(),
            },
          );
        };
        return body();
      },
      recordError,
      zoneValues: zoneValues,
      zoneSpecification: zoneSpecification,
    );
  }

  Future<List<bool>> runTasks(List<FutureOr<void> Function()> tasks) async {
    final results = <bool>[];
    for (final task in tasks) {
      final taskResult = await tryThis(task);
      taskResult.singleActOnFinished(
        onDone: (p0) => results.add(true),
        onError: (p0, _) => results.add(false),
      );
    }
    return results;
  }

  ///local bucket information
  ///will save data with a prefix to avoid collision
  ///
  ///if you don't call [activateLocalStorage] it will be disabled by default
  static const _kBucketPrefix = '$_kModuleName-bucket';
  storage.SharedPreferences? _bucket;
  Future<void> activateLocalStorage() async {
    _bucket = await storage.SharedPreferences.getInstance();
    _taskQueue.execute(_reportBucket);
  }

  Future<void> _reportBucket() async {
    final items = _bucket?.getKeys().where(
          (element) => element.startsWith(_kBucketPrefix),
        );

    if ((items?.isNotEmpty ?? false) == true) {
      _internalLog(
        '''starting to upload locally recorded data 
        found ${items?.length} items to upload''',
      );
      for (final item in items!) {
        final data = converter.jsonDecode(
          _bucket?.getString(item) ?? '{}',
        );
        _taskQueue.addToQueue(
          () => recordRawMap(
            data,
            attachInfo: false,
            onDone: () async {
              await _bucket!.remove(
                item,
              );
            },
          ),
        );
      }
      var count = 0;
      // ignore: unused_local_variable
      await for (final task in _taskQueue.drainStream()) {
        _internalLog(
          'stream draining index: ${count++}',
        );
      }
      _internalLog(
        'done uploading logged data',
      );
    }
  }

  ///log message to console
  void _internalLog(
    String message, {
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
  }) {
    () {
      dev.log(
        message,
        name: _kModuleName,
        error: error,
        level: level,
        sequenceNumber: sequenceNumber,
        stackTrace: stackTrace,
        time: time,
        zone: zone,
      );
    }.runInDebugMode();
  }

  ///check whether app is connected to a local storage or not
  ///
  ///if you don't call [activateLocalStorage] it will be disabled by default
  bool get hasBucket => _bucket != null;

  ///index of crash in a runtime
  static int crashCounter = 0;

  ///where to send crash report
  final Uri? reportUri;

  ///headers of crash report eg. token, ...
  final Map<String, String> _reportHeaders;

  ///extra info to attach to every report
  final Map<String, dynamic> _extraInfo;
  void addExtraInfo(Map<String, dynamic> info) {
    _extraInfo.addAll(info);
  }

  ///callback to call when crash happens to handle internally
  final void Function(Object exception, StackTrace stackTrace)? _onCrash;

  ///[_deviceInfo] and [_appInfo] grabbed with [gatherBasicData]
  ///
  ///if you don't call [gatherBasicData] it will pass an error message
  Future<void> gatherBasicData() async {
    final deviceInfo = device_info.DeviceInfoPlugin();
    _deviceInfo = {'error': 'current platform is not supported'};
    if (Platform.isAndroid) {
      _deviceInfo = (await deviceInfo.androidInfo).toMap();
    } else if (Platform.isIOS) {
      _deviceInfo = (await deviceInfo.iosInfo).toMap();
    }
    _cleanFromDeviceInfo.forEach(_deviceInfo.remove);

    final packageInfo = await package_info.PackageInfo.fromPlatform();
    _appInfo = {
      'appName': packageInfo.appName,
      'version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
      'packageName': packageInfo.packageName,
      'signingKey': packageInfo.buildSignature,
    };
    _hasBasicData = true;
    _internalLog(
      'Basic Data gathered',
    );
  }

  ///check module has device and app info
  bool _hasBasicData = false;

  ///check module has device and app info
  bool get hasBasicData => _hasBasicData;
  final List<String> _cleanFromDeviceInfo;
  Map<String, dynamic> get deviceInfo => Map.from(_deviceInfo);

  ///device info gathered with [gatherBasicData]
  Map<String, dynamic> _deviceInfo = <String, dynamic>{
    'error': 'have not been initialized',
  };

  ///app info gathered with [gatherBasicData]
  Map<String, dynamic> _appInfo = <String, dynamic>{
    'error': 'have not been initialized',
  };

  ///crashlytix settings map
  Map<String, dynamic> get crashlytixLog => {
        'hasBasicData': hasBasicData,
        'hasABucket': hasBucket,
      };

  ///report log to console in debug mode
  void logCrash(Object? exception, StackTrace stackTrace) {
    _internalLog(
      'found a crash',
      time: DateTime.now(),
      level: 1200,
      stackTrace: stackTrace,
      error: exception,
    );
  }

  ///will pass its params to [trySync]
  snap.DataSnapHandler<TResult> call<TResult>(
    TResult Function() function, {
    Map<String, dynamic> extraInfo = const {},
  }) =>
      trySync(function, extraInfo: extraInfo);

  ///will run the given function in try catch clause
  ///
  ///if faces error it will call [recordError]
  ///
  ///return type is a future of [snap.DataSnapHandler] so
  ///you can handle result with it
  snap.DataSnapHandler<TResult> trySync<TResult>(
    TResult Function() function, {
    Map<String, dynamic> extraInfo = const {},
  }) {
    try {
      final result = function();
      return snap.DataSnapHandler<TResult>.done(
        data: result,
        sender: StackTrace.current,
      );
    } catch (ex, st) {
      recordError(ex, st, extraInfo);
      return snap.DataSnapHandler<TResult>.error(
        exception: ex,
        sender: st,
      );
    }
  }

  ///will run the given function in try catch clause
  ///
  ///if faces error it will call [recordError]
  ///
  ///return type is a future of [snap.DataSnapHandler] so
  ///you can handle result with it
  @Deprecated('use tryAsync instead')
  FutureOr<snap.DataSnapHandler<TResult>> tryThis<TResult>(
    FutureOr<TResult> Function() function, {
    Map<String, dynamic> extraInfo = const {},
  }) =>
      tryAsync(function, extraInfo: extraInfo);

  ///will run the given function in try catch clause
  ///
  ///if faces error it will call [recordError]
  ///
  ///return type is a future of [snap.DataSnapHandler] so
  ///you can handle result with it
  Future<snap.DataSnapHandler<TResult>> tryAsync<TResult>(
    FutureOr<TResult> Function() function, {
    Map<String, dynamic> extraInfo = const {},
  }) async {
    try {
      final result = await function();
      return snap.DataSnapHandler<TResult>.done(
        data: result,
        sender: StackTrace.current,
      );
    } catch (ex, st) {
      recordError(ex, st, extraInfo);
      return snap.DataSnapHandler<TResult>.error(
        exception: ex,
        sender: st,
      );
    }
  }

  ///recording raw map data as json
  ///
  ///if failed to send and [hasBucket] is true it will save it locally
  ///and try to send it later
  ///
  ///by later i mean when calling [_reportBucket]
  ///that is when app is connected to a local storage via [activateLocalStorage]
  ///or it sent a report successfully
  Future<void> recordRawMap(
    Map<String, dynamic> data, {
    bool attachInfo = true,
    void Function()? onDone,
  }) async {
    final crashTime = DateTime.now().millisecondsSinceEpoch;

    /// if you did set the [reportUri] it will use it to upload the error
    /// information
    if (reportUri != null) {
      final params = PostRequestParams(
        reportUri!,
        _reportHeaders,
        attachInfo
            ? {
                'data': {
                  'packageInfo': _appInfo,
                  'deviceInfo': _deviceInfo,
                  'errorTime': crashTime,
                  ...data,
                  'crashIndex': crashCounter++,
                  'extraInfo': _extraInfo,
                  '${_kModuleName}Log': crashlytixLog,
                },
              }
            : data,
        null,
      );
      await _taskQueue.execute(
        () => treads.IsolationCore.createIsolateForSingleTask<bool>(
          task: onlineReport,
          taskParams: params,
          debugName: 'crash_report_${params.hashCode}',
        ).then(
          (value) {
            value.singleActOnFinished(
              onDone: (result) {
                if (result != null) {
                  if (attachInfo) {
                    _taskQueue.execute(_reportBucket);
                  }
                  if (onDone != null) onDone();
                } else {
                  if (attachInfo) {
                    final logData = converter.jsonEncode(params.body);
                    _internalLog(
                      '''cannot upload log data for now it will be placed in ${logData.hashCode}''',
                    );
                    _bucket?.setString(
                      '$_kBucketPrefix-${logData.hashCode}',
                      logData,
                    );
                  }
                }
              },
              onError: (_, stack) {
                if (attachInfo) {
                  final logData = converter.jsonEncode(params.body);
                  _internalLog(
                    '''cannot upload log data for now it will be placed in ${logData.hashCode}''',
                  );
                  _bucket?.setString(
                    '$_kBucketPrefix-${logData.hashCode}',
                    logData,
                  );
                }
              },
            );
          },
        ),
      );
    }
  }

  Future<void> cleanBucket() async {
    _bucket?.clear();
  }

  ///[Object] ex is the exception
  ///[StackTrace] st is the stack trace
  ///[Map<String, dynamic>] extraInfo is the extra info to attach to the report
  ///will log crash with [recordRawMap]
  Future<void> recordError(
    Object ex,
    StackTrace st, [
    Map<String, dynamic> extraInfo = const {},
  ]) async {
    (_onCrash ?? (_, __) {})(ex, st);
    logCrash(ex, st);
    await _taskQueue.execute(
      () => recordRawMap({
        'exception': ex.toString(),
        'stacktrace': st.toString(),
        if (extraInfo.isNotEmpty) 'carryInfo': extraInfo,
      }),
    );
  }

  ///report error to server
  static Future<bool> onlineReport(dynamic input) async {
    final params = input as PostRequestParams;
    try {
      await Dio().postUri(
        params.uri,
        data: converter.jsonEncode(
          params.body,
        ),
        options: Options(
          headers: params.headers,
        ),
      );
      return true;
    } catch (e, st) {
      'Request failed'.log(
        time: DateTime.now(),
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}

class PostRequestParams {
  final Uri uri;
  final Map<String, String>? headers;
  final Map<String, dynamic>? body;
  final Map<String, dynamic>? params;
  const PostRequestParams(
    this.uri,
    this.headers,
    this.body,
    this.params,
  );

  PostRequestParams copyWith({
    Uri? uri,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? params,
  }) {
    return PostRequestParams(
      uri ?? this.uri,
      headers ?? this.headers,
      body ?? this.body,
      params ?? this.params,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uri': uri.path,
      'headers': headers,
      'body': body,
      'params': params,
    };
  }

  factory PostRequestParams.fromMap(Map<String, dynamic> map) {
    return PostRequestParams(
      Uri.parse(map['uri']),
      Map<String, String>.from(map['headers']),
      Map<String, dynamic>.from(map['body']),
      Map<String, dynamic>.from(map['params']),
    );
  }

  String toJson() => converter.jsonEncode(toMap());

  factory PostRequestParams.fromJson(
    String source,
  ) =>
      PostRequestParams.fromMap(
        converter.jsonDecode(
          source,
        ),
      );

  @override
  String toString() {
    return '''PostRequestParams(uri: $uri, headers: $headers, body: $body, params: $params)''';
  }
}
