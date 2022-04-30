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
  static CrashHandler get instance => _instance;
  late SharedPreferences? _bucket;
  static const _kModuleName = 'Crashlytix';
  static const _bucketPrefix = '$_kModuleName-bucket';
  static late CrashHandler _instance;
  static int crashCounter = 0;
  final Uri? reportUri;
  final Map<String, String>? _reportHeaders;
  final Map<String, dynamic>? _extraInfo;
  final void Function(Object, StackTrace)? _onCrash;
  Map<String, dynamic> _deviceInfo = <String, dynamic>{
    'error': 'have not been initialized',
  };
  Map<String, dynamic> _appInfo = <String, dynamic>{
    'error': 'have not been initialized',
  };
  bool hasBasicData = false;
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
  Future<void> activateLocalStorage() async {
    _bucket = await SharedPreferences.getInstance();
    _reportBucket();
  }

  Future<void> gatherBasicData() async {
    final deviceInfo = DeviceInfoPlugin();
    _deviceInfo = {'error': 'current platform is not supported'};
    if (Platform.isAndroid) {
      _deviceInfo = (await deviceInfo.androidInfo).toMap();
    } else if (Platform.isIOS) {
      _deviceInfo = (await deviceInfo.iosInfo).toMap();
    }
    final packageInfo = await PackageInfo.fromPlatform();
    _appInfo = {
      'appName': packageInfo.appName,
      'version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
      'packageName': packageInfo.packageName,
      'signingKey': packageInfo.buildSignature,
    };
    hasBasicData = true;
    dev.log('Basic Data gathered', name: _kModuleName);
  }

  Future<Map<String, dynamic>> crashlyticsLog() async {
    final result = <String, dynamic>{};
    result.addAll({'hasBasicData': hasBasicData});
    return result;
  }

  void logCrash(Object? exception, StackTrace stackTrace) {
    // final reportData = {
    //   'exception': exception,
    //   'stackTrace': stackTrace,
    // };
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
              '$_kModuleName Log': await crashlyticsLog(),
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
                  '$_bucketPrefix-${logData.hashCode}',
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

  Future<void> _reportBucket() async {
    dev.log(
      'starting to upload logged data',
      name: _kModuleName,
    );
    final items = _bucket?.getKeys().where(
          (element) => element.startsWith(_bucketPrefix),
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
