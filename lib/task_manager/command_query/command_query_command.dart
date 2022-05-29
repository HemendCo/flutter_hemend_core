import 'dart:async' show FutureOr;

import '../../debug/error_handler.dart';
import 'command_query_params.dart';

class CommandModel {
  final String command;
  final List<String> forcedParams;
  final List<String> optionalParams;

  final String? Function(
    Parameters,
    Map<String, dynamic> results,
  )? optionalAssertion;

  final FutureOr<dynamic> Function(
    Parameters,
    Map<String, dynamic> results,
  ) commandRunner;

  const CommandModel({
    required this.command,
    required this.forcedParams,
    required this.optionalParams,
    required this.commandRunner,
    this.optionalAssertion,
  });

  FutureOr<T> call<T>(Parameters params, Map<String, dynamic> results) async {
    final optionalAssertResult = (optionalAssertion ?? (_, __) => null)(
      params,
      results,
    );
    final paramsChk = extraAssertion(params);
    if (optionalAssertResult != null || paramsChk != null) {
      throw ErrorHandler('''Assertion failed
          Command: $command
          Params: $params
          Log:
          $paramsChk
          $optionalAssertResult
          ''', {
        ErrorType.variableError,
      });
    }
    final reflectedParams = Map.fromEntries(
      params.entries.map((e) {
        final value = e.value;
        if (value.isFromResults) {
          return results[value.value];
        }
        return MapEntry(e.key, value);
      }),
    );

    return await commandRunner(reflectedParams, results);
  }

  FutureOr<T> run<T>(Parameters params, Map<String, dynamic> results) {
    return this(params, results);
  }

  String? extraAssertion(Parameters params) {
    final sentParams = params.entries.map((e) => e.key);
    final allParams = forcedParams + optionalParams;
    final result = StringBuffer();
    final missingForcedParams = forcedParams.any(
      (element) => !sentParams.contains(element),
    );
    if (missingForcedParams) {
      result.writeln('Missing forced params');
    }
    final extraParams = sentParams.any(
      (element) => !allParams.contains(element),
    );
    if (extraParams) {
      result.writeln('Extra params found');
    }
    if (result.isNotEmpty) {
      return '$result\n';
    }
    return null;
  }
}
