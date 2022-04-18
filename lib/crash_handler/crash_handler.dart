import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../debug/developer_tools.dart';
import '../object_controllers/data_snap_handler/data_snap_handler.dart' as snap;
import '../task_manager/isolate_manager/isolation_core.dart';

class CrashHandler {
  static CrashHandler get instance => _instance;
  static const _kModuleName = 'Crashlytix';
  static late CrashHandler _instance;
  static int crashCounter = 0;
  final Uri _reportUri;
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
  CrashHandler.register(
    this._reportUri, {
    void Function(Object, StackTrace)? onCrash,
    Map<String, String>? reportHeaders,
    Map<String, dynamic>? extraInfo,
  })  : _extraInfo = extraInfo,
        _onCrash = onCrash,
        _reportHeaders = reportHeaders {
    _instance = this;
    dev.log('$_kModuleName initialized');
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
    final reportData = {
      'exception': exception,
      'stackTrace': stackTrace,
    };
    () {
      reportData.log(
        time: DateTime.now(),
        error: _kModuleName,
      );
    }.runInDebugMode();
  }

  FutureOr<snap.DataSnapHandler<TResult>> call<TResult>(
    FutureOr<TResult> Function() function,
  ) async {
    try {
      final result = await function();
      return snap.DataSnapHandler<TResult>.done(data: result);
    } catch (ex, st) {
      (_onCrash ?? (_, __) {})(ex, st);
      logCrash(ex, st);
      final crashTime = DateTime.now().millisecondsSinceEpoch;

      final params = PostRequestParams(
        _reportUri,
        _reportHeaders,
        {
          'data': jsonEncode(
            {
              'packageInfo': _appInfo,
              'deviceInfo': _deviceInfo,
              'errorTime': crashTime,
              'exception': ex.toString(),
              'stacktrace': st.toString(),
              'crashIndex': (crashCounter++).toString(),
              'extraInfo': _extraInfo ?? 'none',
              '$_kModuleName Log': await crashlyticsLog(),
            },
          )
        },
        null,
      );
      IsolationCore.createIsolateForSingleTask<void>(
        task: onlineReport,
        taskParams: params,
        debugName: 'crash_report_$crashCounter',
      );

      return snap.DataSnapHandler<TResult>.error(
        exception: ex,
        sender: st,
      );
    }
  }

  static Future<void> onlineReport(dynamic input) async {
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
