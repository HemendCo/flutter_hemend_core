import 'dart:async' show FutureOr;

import '../../debug/error_handler.dart';
import '../../extensions/list_verification_tools.dart';
import 'command_query_params.dart' show Parameters, ResultTable;

class CommandModel {
  ///instruction name
  final String command;

  ///parameters that command will break on absence
  final List<String> forcedParams;

  ///extra optional parameters that command can use but are not required
  ///
  ///internal assertion test will use this list to check parameters given
  ///to check for extra unusable parameters and throw error for them
  final List<String> optionalParams;

  ///optional assertion test that will be run before running command to validate
  ///parameters given or other cases
  ///
  ///for more information => [extraAssertion]
  final String? Function(
    Parameters,
    ResultTable results,
  )? optionalAssertion;

  ///the function that this instruction will call
  ///it will have parameters given via [Parameters]
  ///and will will receive older result table as [ResultTable]
  ///the key of result table is commandTag and value is result of command
  ///
  ///result type is [FutureOr] so it can be called like async methods
  ///currently it will not support [Stream]
  final FutureOr<dynamic> Function(
    Parameters,
    ResultTable,
  ) commandRunner;

  const CommandModel({
    required this.command,
    required this.forcedParams,
    required this.optionalParams,
    required this.commandRunner,
    this.optionalAssertion,
  });

  ///command runner will take [params] and older [results]
  ///
  ///will run optional assertion [optionalAssertion]
  ///
  ///then will run internal assertion [extraAssertion] to check parameters
  ///
  ///if [optionalAssertion] or [extraAssertion] both where ok
  ///and returned *null* value then it will run [commandRunner]

  FutureOr<T> call<T>(Parameters params, ResultTable results) async {
    ///testing optional assertion
    final optionalAssertResult = (optionalAssertion ?? (_, __) => null)(
      params,
      results,
    );

    ///checking parameters before running command
    final paramsChk = extraAssertion(params);

    ///throw if one or all of assertions failed
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

    return await commandRunner(params, results);
  }

  ///points to the callable method
  FutureOr<T> run<T>(
    Parameters params,
    ResultTable results,
  ) =>
      this(
        params,
        results,
      );

  ///will return nullable [String] string as result of assertion
  ///if result is null then it means that assertion passed
  ///otherwise it will return [String] with error message
  String? extraAssertion(Parameters params) {
    final result = StringBuffer();
    final sentParams = params.keys;
    final allParams = forcedParams + optionalParams;

    ///check missing forced params
    final missingForcedParams = sentParams.getMissingItems(forcedParams);
    if (missingForcedParams.isNotEmpty) {
      result.writeln('Missing forced params: $missingForcedParams\n');
    }

    ///check extra given params
    final extraParams = allParams.getMissingItems(sentParams);
    if (extraParams.isNotEmpty) {
      result.writeln('Extra params found: $extraParams\n');
    }

    ///return result if has any data
    if (result.isNotEmpty) {
      return '$result';
    }
    return null;
  }
}
