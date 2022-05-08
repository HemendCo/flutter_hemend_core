import '../../debug/error_handler.dart';
import 'command_query_params.dart';

class CommandModel {
  final String command;
  final List<String> forcedParams;
  final List<String> optionalParams;
  final String? Function(Parameters, Map<String, dynamic> results)? optionalAssertion;
  final dynamic Function(Parameters, Map<String, dynamic> results) commandRunner;
  const CommandModel({
    required this.command,
    required this.forcedParams,
    required this.optionalParams,
    required this.commandRunner,
    this.optionalAssertion,
  });

  T call<T>(Parameters params, Map<String, dynamic> results) {
    final optionalAssertResult = (optionalAssertion ?? (_, __) => null)(params, results);
    final paramsChk = extraAssertion(params);
    if (optionalAssertResult != null || paramsChk != null) {
      throw ErrorHandler(
          'Assertion failed\nCommand: $command\nParams: $params\nLog: \n$paramsChk$optionalAssertResult', {
        ErrorType.variableError,
      });
    }
    return commandRunner(params, results);
  }

  T run<T>(Parameters params, Map<String, dynamic> results) {
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
    final extraParams = sentParams.any((element) => !allParams.contains(element));
    if (extraParams) {
      result.writeln('Extra params found');
    }
    if (result.isNotEmpty) {
      return result.toString() + '\n';
    }
    return null;
  }
}
