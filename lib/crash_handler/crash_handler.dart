// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
// import 'package:logging/logging.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../debug/developer_tools.dart';
import '../object_controllers/data_snap_handler/data_snap_handler.dart' as snap;
import '../task_manager/isolate_manager/isolation_core.dart';

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
  })  : _extraInfo = extraInfo,
        _onCrash = onCrash,
        _reportHeaders = reportHeaders {
    _instance = this;
    dev.log(
      '$_kModuleName initialized',
      name: _kModuleName,
    );
  }

  ///local bucket information
  ///will save data with a prefix to avoid collision
  ///
  ///if you don't call [activateLocalStorage] it will be disabled by default
  static const _kBucketPrefix = '$_kModuleName-bucket';
  SharedPreferences? _bucket;
  Future<void> activateLocalStorage() async {
    _bucket = await SharedPreferences.getInstance();
    _reportBucket();
  }

  Future<void> _reportBucket() async {
    dev.log(
      'starting to upload logged data',
      name: _kModuleName,
    );
    final items = _bucket?.getKeys().where(
          (element) => element.startsWith(_kBucketPrefix),
        );

    dev.log(
      'found ${items?.length} items to upload',
      name: _kModuleName,
    );
    if ((items?.isNotEmpty ?? false) == true) {
      for (final item in items!) {
        final data = jsonDecode(_bucket?.getString(item) ?? '{}');
        await recordRawMap(data).then(
          (value) async =>
              (await _bucket?.remove(
                item,
              )) ??
              false,
        );
      }
    }
    dev.log(
      'done uploading logged data',
      name: _kModuleName,
    );
  }

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
    final deviceInfo = DeviceInfoPlugin();
    _deviceInfo = {'error': 'current platform is not supported'};
    if (Platform.isAndroid) {
      _deviceInfo = (await deviceInfo.androidInfo).toMap();
    } else if (Platform.isIOS) {
      _deviceInfo = (await deviceInfo.iosInfo).toMap();
    }
    _deviceInfo=_deviceInfo.remove('systemFeatures')
    final packageInfo = await PackageInfo.fromPlatform();
    _appInfo = {
      'appName': packageInfo.appName,
      'version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
      'packageName': packageInfo.packageName,
      'signingKey': packageInfo.buildSignature,
    };
    _hasBasicData = true;
    dev.log('Basic Data gathered', name: _kModuleName);
  }

  bool _hasBasicData = false;
  bool get hasBasicData => _hasBasicData;
  Map<String, dynamic> _deviceInfo = <String, dynamic>{
    'error': 'have not been initialized',
  };
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
    () {
      dev.log(
        'found a crash',
        time: DateTime.now(),
        level: 1200,
        stackTrace: stackTrace,
        error: exception,
        name: _kModuleName,
      );
    }.runInDebugMode();
  }

  FutureOr<snap.DataSnapHandler<TResult>> call<TResult>(
    FutureOr<TResult> Function() function, {
    Map<String, dynamic> extraInfo = const {},
  }) =>
      tryThis(function, extraInfo: extraInfo);

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

  Future<void> recordRawMap(Map<String, dynamic> data) async {
    final crashTime = DateTime.now().millisecondsSinceEpoch;
    if (reportUri != null) {
      final params = PostRequestParams(
        reportUri!,
        _reportHeaders,
        {
          'data': jsonEncode(
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
        },
        null,
      );
      await IsolationCore.createIsolateForSingleTask<bool>(
        task: onlineReport,
        taskParams: params,
        debugName: 'crash_report_$crashCounter',
      ).then(
        (value) {
          print(value.status);

          value.singleActOnFinished(
            onDone: (result) {
              if (result ?? false == true) {
                _reportBucket();
              } else {
                final logData = jsonEncode(data);
                dev.log(
                  'cannot upload log data for now it will be placed in ${logData.hashCode}',
                  name: _kModuleName,
                );
                _bucket?.setString(
                  '$_kBucketPrefix-${logData.hashCode}',
                  logData,
                );
              }
            },
            onError: (_) {},
          );
        },
      );
    }
  }

  ///[Object] ex is the exception
  ///[StackTrace] st is the stack trace
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
      final result = await http.post(
        params.uri,
        body: params.body,
        headers: params.headers,
      );
      () {
        result.body.log(
          time: DateTime.now(),
          name: _kModuleName,
        );
      }.runInDebugMode();
      return true;
    } catch (e, st) {
      () {
        final error = <String, dynamic>{
          'error': 'Request failed',
          'exception': e.toString(),
          'stacktrace': st.toString(),
        };
        error.log(
          time: DateTime.now(),
          error: '$_kModuleName Crash',
        );
      }.runInDebugMode();
      return false;
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
