import 'dart:convert';

import 'package:dio/dio.dart';

class DioCurlRequestInfo {
  final RequestOptions requestOptions;
  final String? curl;
  final DateTime time;

  DioCurlRequestInfo({
    required this.requestOptions,
    required this.curl,
    required this.time,
  });
}

class DioCurlInterceptor extends Interceptor {
  final bool printOnSuccess;
  final bool convertFormData;

  final void Function(
    DioCurlRequestInfo info,
  ) onLog;

  DioCurlInterceptor({
    this.printOnSuccess = true,
    this.convertFormData = true,
    required this.onLog,
  });

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    _renderCurlRepresentation(err.requestOptions);
    return handler.next(err);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (printOnSuccess) {
      _renderCurlRepresentation(response.requestOptions);
    }

    /// continue
    return handler.next(response);
  }

  void _renderCurlRepresentation(RequestOptions requestOptions) {
    try {
      final curl = _cURLRepresentation(requestOptions);
      onLog(
        DioCurlRequestInfo(
          requestOptions: requestOptions,
          curl: curl,
          time: DateTime.now(),
        ),
      );
    } catch (err) {
      onLog(
        DioCurlRequestInfo(
          requestOptions: requestOptions,
          curl: null,
          time: DateTime.now(),
        ),
      );
    }
  }

  String _cURLRepresentation(RequestOptions options) {
    final components = ['curl -i'];

    options.headers.forEach((k, v) {
      if (!['Cookie', 'content-length'].contains(k)) {
        components.add('-H "$k: $v"');
      }
    });

    if (options.data != null || options.method.toLowerCase() == 'post') {
      if (options.data is FormData && convertFormData) {
        options.data = Map.fromEntries((options.data as FormData).fields);
      }

      final data = json.encode(options.data ?? {});
      components.add('-d $data');
    }
    var contains = false;
    for (final element in components) {
      if (element.contains('-X')) {
        contains = true;
      }
    }
    if (contains) {
      components.add('-X ${options.method}');
    }
    components.add('"${options.uri.toString()}"');

    return components.join(' \\\n\t');
  }
}
