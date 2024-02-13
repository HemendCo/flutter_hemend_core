import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hemend_logger/hemend_logger.dart';

class DioLoggerException implements Exception {
  DioLoggerException(this.message);

  final String message;
  @override
  String toString() {
    return 'DioLoggerException: $message';
  }
}

class CurlLoggerDioInterceptor extends Interceptor {
  CurlLoggerDioInterceptor({
    required this.logger,
    this.multilineUnixFormat = true,
  });
  final bool multilineUnixFormat;
  final Logger logger;

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    logger.severe(
      _renderCurlRepresentation(err.requestOptions),
      err,
    );

    return handler.next(err);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    logger.fine(
      _renderCurlRepresentation(response.requestOptions),
    );

    /// continue
    return handler.next(response);
  }

  String _renderCurlRepresentation(RequestOptions requestOptions) {
    try {
      final command = _cURLRepresentation(requestOptions);
      return command;
    } on Object catch (err, st) {
      logger.shout(
        'Fall into an error during converting request to curl representation',
        err,
        st,
      );
      throw DioLoggerException('cannot convert request to curl representation');
    }
  }

  String _cURLRepresentation(RequestOptions options) {
    final buffer = StringBuffer('curl ') //
      ..addParameter(
        '-i',
        multiline: multilineUnixFormat,
      );

    options.headers.forEach((k, v) {
      if (!['Cookie', 'content-length'].contains(k)) {
        final headerValue = '-H "$k: $v"';
        buffer.addParameter(
          headerValue,
          multiline: multilineUnixFormat,
        );
      }
    });

    if (options.data != null) {
      /// FormData can't be JSON-serialized, so keep only their field attributes
      final data = options.data;
      if (data is FormData) {
        for (final field in data.fields) {
          buffer.addParameter(
            "-F '${field.key}=\"${field.value}\"'",
            multiline: multilineUnixFormat,
          );
        }
      } else if (data is Map) {
        final rawData = jsonEncode(data);
        buffer.addParameter(
          '--data-raw "$rawData"',
          multiline: multilineUnixFormat,
        );
      } else if (data is String) {
        buffer.addParameter(
          '--data-raw "$data"',
          multiline: multilineUnixFormat,
        );
      }
    }
    buffer
      ..addParameter(
        '-X ${options.method.toUpperCase()}',
        multiline: multilineUnixFormat,
      )
      ..write(
        '"${options.uri}"',
        // multiline: multilineUnixFormat,
      );

    return buffer.toString();
  }
}

extension on StringBuffer {
  void addParameter(String parameter, {required bool multiline}) {
    write(parameter);
    write(' ');
    if (multiline) {
      write('\\\n\t');
    }
  }
}
