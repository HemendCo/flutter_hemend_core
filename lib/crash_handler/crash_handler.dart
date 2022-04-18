import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../debug/developer_tools.dart';
import '../object_controllers/data_snap_handler/data_snap_handler.dart' as snap;
import '../task_manager/isolate_manager/isolation_core.dart';

class CrashHandler {
  static CrashHandler get instance => _instance;
  static late CrashHandler _instance;
  static int crashCounter = 0;
  final Uri _reportUri;
  final Map<String, String>? _reportHeaders;
  final void Function(Object, StackTrace) _onCrash;
  CrashHandler.register(this._reportUri, this._onCrash, this._reportHeaders) {
    _instance = this;
  }

  ///return result of a function in a try-catch block and return the result
  FutureOr<snap.DataSnapHandler<TResult>> call<TResult>(
    FutureOr<TResult> Function() function,
  ) async {
    try {
      final result = await function();
      return snap.DataSnapHandler<TResult>.done(data: result);
    } catch (ex, st) {
      _onCrash(ex, st);
      final packageInfo = await PackageInfo.fromPlatform();
      final crashTime = DateTime.now().millisecondsSinceEpoch;
      final appInfo = {
        'appName': packageInfo.appName,
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'packageName': packageInfo.packageName,
        'signingKey': packageInfo.buildSignature,
      };
      final deviceInfo = DeviceInfoPlugin();
      Map<String, dynamic> deviceInfoMap = {'error': 'cannot read info'};
      if (Platform.isAndroid) {
        deviceInfoMap = (await deviceInfo.androidInfo).toMap();
      } else if (Platform.isIOS) {
        deviceInfoMap = (await deviceInfo.iosInfo).toMap();
      }

      final params = PostRequestParams(
        _reportUri,
        _reportHeaders,
        {
          'data': jsonEncode(
            {
              'packageInfo': appInfo,
              'deviceInfo': deviceInfoMap,
              'errorTime': crashTime,
              'exception': ex.toString(),
              'stacktrace': st.toString(),
              'crashIndex': (crashCounter++).toString(),
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

    final result = await http.post(params.uri, body: params.body, headers: params.headers);
    result.body.printToConsole.runInDebugMode();
  }
}

class PostRequestParams {
  final Uri uri;
  final Map<String, String>? headers;
  final Map<String, dynamic>? body;
  final Map<String, dynamic>? params;
  const PostRequestParams(this.uri, this.headers, this.body, this.params);
}
