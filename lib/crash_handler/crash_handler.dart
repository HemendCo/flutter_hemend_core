// ignore_for_file: lines_longer_than_80_chars

import 'dart:async' show Future, FutureOr, Zone, ZoneSpecification, runZonedGuarded;
import 'dart:convert' as converter show jsonDecode, jsonEncode;
import 'dart:developer' as dev;
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart' as device_info show DeviceInfoPlugin;
import 'package:flutter/material.dart' as ui_part;
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart' as package_info show PackageInfo;
import 'package:shared_preferences/shared_preferences.dart' as storage show SharedPreferences;

import '../debug/developer_tools.dart';
import '../object_controllers/data_snap_handler/data_snap_handler.dart' as snap;
import '../task_manager/isolate_manager/isolation_core.dart' as treads show IsolationCore;

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
  static CrashHandler get instance => _instance;
  static late CrashHandler _instance;
  CrashHandler.register({
    this.reportUri,
    void Function(Object, StackTrace)? onCrash,
    Map<String, String>? reportHeaders,
    Map<String, dynamic>? extraInfo,
    List<String> cleanFromDeviceInfo = const [
      'systemFeatures',
    ],

    ///it is a placeholder for crashed widgets
    ui_part.Widget Function(ui_part.FlutterErrorDetails)? errorWidget,
  })  : _extraInfo = extraInfo,
        _onCrash = onCrash,
        _cleanFromDeviceInfo = cleanFromDeviceInfo,
        _reportHeaders = reportHeaders {
    _instance = this;

    ///will replace (red in debug mode / grey in release mode) default error widget and will catch its error and report it
    ui_part.ErrorWidget.builder = (ui_part.FlutterErrorDetails details) {
      recordError(details.exception, details.stack ?? StackTrace.empty, {'fullErrorLog': details.toString()});
      return (errorWidget ??
          (_) => ui_part.Material(
                child: ui_part.Container(
                  color: ui_part.Colors.red,
                  child: const ui_part.Center(
                    child: ui_part.Text(
                      'found a bug inside this view.',
                      style: ui_part.TextStyle(color: ui_part.Colors.white),
                    ),
                  ),
                ),
              ))(details);
    };

    _internalLog(
      '$_kModuleName initialized',
    );
  }
  R? runZoned<R>(
    R Function() body, {
    Map<Object?, Object?>? zoneValues,
    ZoneSpecification? zoneSpecification,
  }) {
    return runZonedGuarded(
      body,
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
        onError: (p0) => results.add(false),
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
    _reportBucket();
  }

  Future<void> _reportBucket() async {
    final items = _bucket?.getKeys().where(
          (element) => element.startsWith(_kBucketPrefix),
        );

    if ((items?.isNotEmpty ?? false) == true) {
      _internalLog(
        'starting to upload locally recorded data\nfound ${items?.length} items to upload',
      );
      for (final item in items!) {
        final data = converter.jsonDecode(_bucket?.getString(item) ?? '{}');
        await recordRawMap(data).then(
          (value) async =>
              (await _bucket?.remove(
                item,
              )) ??
              false,
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
  final Map<String, String>? _reportHeaders;

  ///extra info to attach to every report
  Map<String, dynamic>? _extraInfo;
  void addExtraInfo(Map<String, dynamic> info) {
    _extraInfo ??= {};
    _extraInfo!.addAll(info);
  }

  ///callback to call when crash happens to handle internally
  final void Function(Object, StackTrace)? _onCrash;

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

  ///will pass its params to [tryThis]
  FutureOr<snap.DataSnapHandler<TResult>> call<TResult>(
    FutureOr<TResult> Function() function, {
    Map<String, dynamic> extraInfo = const {},
  }) =>
      tryThis(function, extraInfo: extraInfo);

  ///will run the given function in try catch clause
  ///
  ///if faces error it will call [recordError]
  ///
  ///return type is a future of [snap.DataSnapHandler] so you can handle result with it
  FutureOr<snap.DataSnapHandler<TResult>> tryThis<TResult>(
    FutureOr<TResult> Function() function, {
    Map<String, dynamic> extraInfo = const {},
  }) async {
    try {
      final result = await function();
      return snap.DataSnapHandler<TResult>.done(data: result);
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
  Future<void> recordRawMap(Map<String, dynamic> data, {bool attachInfo = true}) async {
    final crashTime = DateTime.now().millisecondsSinceEpoch;
    if (reportUri != null) {
      final params = PostRequestParams(
        reportUri!,
        _reportHeaders,
        attachInfo
            ? {
                'data': converter.jsonEncode(
                  {
                    'packageInfo': _appInfo,
                    'deviceInfo': _deviceInfo,
                    'errorTime': crashTime,
                    ...data,
                    'crashIndex': (crashCounter++).toString(),
                    'extraInfo': _extraInfo ?? 'none',
                    '$_kModuleName Log': crashlytixLog,
                  },
                )
              }
            : data,
        null,
      );
      await treads.IsolationCore.createIsolateForSingleTask<bool>(
        task: onlineReport,
        taskParams: params,
        debugName: 'crash_report_$crashCounter',
      ).then(
        (value) {
          value.singleActOnFinished(
            onDone: (result) {
              if (result ?? false == true) {
                _reportBucket();
              } else {
                final logData = converter.jsonEncode(params);
                _internalLog(
                  'cannot upload log data for now it will be placed in ${logData.hashCode}',
                );
                _bucket?.setString(
                  '$_kBucketPrefix-${logData.hashCode}',
                  logData,
                );
              }
            },
            onError: (_) {
              final logData = converter.jsonEncode(params);
              _internalLog(
                'cannot upload log data for now it will be placed in ${logData.hashCode}',
              );
              _bucket?.setString(
                '$_kBucketPrefix-${logData.hashCode}',
                logData,
              );
            },
          );
        },
      );
    }
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
    await recordRawMap({
      'exception': ex.toString(),
      'stacktrace': st.toString(),
      'carryInfo': extraInfo,
    });
  }

  ///report error to server
  static Future<bool> onlineReport(dynamic input) async {
    final params = input as PostRequestParams;
    try {
      await http.post(
        params.uri,
        body: params.body,
        headers: params.headers,
      );
      return true;
    } catch (e, st) {
      CrashHandler.instance._internalLog(
        'Request failed',
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
  const PostRequestParams(this.uri, this.headers, this.body, this.params);
}
