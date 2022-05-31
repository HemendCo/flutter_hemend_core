import 'dart:async';
import 'dart:convert' show json;

import '../../debug/error_handler.dart';
import '../../extensions/map_verification_tools.dart';
import 'command_query.dart' show CommandModel, ParamsModel, ResultTable;

typedef InstructionMap = Map<String, CommandModel>;

///command runner will take instruction set named [commands]
///then can run command by using [parsAndRunFromString] or [parsAndRunFromJson]
class CommandQueryParser {
  /// instruction set of this query parser
  ///
  /// example :
  ///
  /// ```dart
  /// InstructionSet commandMap = InstructionSet(const [
  ///   CommandModel(
  ///       command: 'ContainerGenerator',
  ///       commandRunner: (params,results)=>Container(),
  ///       forcedParams: [
  ///         'width',
  ///         'height',
  ///         'decoration',
  ///       ],
  ///       optionalParams: [
  ///         'margin',
  ///         'padding',
  ///         'alignment',
  ///       ],
  ///     ),
  ///   ],
  /// );
  /// ```
  final InstructionSet commands;

  /// this holds result of each command after execution if flags let it to do
  ResultTable _results = {};

  T? getResultOf<T>(String key, {bool isRequired = true}) {
    if (!_results.containsKey(key) && isRequired) {
      throw ErrorHandler(
        '''

cannot find required result from $key''',
        <ErrorType>{
          ErrorType.variableError,
          ErrorType.notFound,
        },
      );
    }

    final result = _results[key];
    if (result is! T) {
      throw ErrorHandler(
        '''

found a result for $key but its not of type $T''',
        <ErrorType>{
          ErrorType.variableError,
        },
      );
    }
    return _results[key];
  }

  void resetResultTable() {
    _results.clear();
  }

  CommandQueryParser({
    required this.commands,
  });

  /// # Deprecated
  /// use [parsAndRunFromJson] instead
  /// it wont receive any update anymore (2022,May,31)
  /// and will be removed in the future
  ///
  /// parses and run command from [query]
  ///
  /// if [query] is not valid it will throw error
  ///
  /// if [query] is valid it will run command and return result
  ///
  /// if [resetOldResultTable] is true it will call [resetResultTable] before
  /// running any command
  ///
  /// if [storeResultOfThisRunInResultsTable] is false it wont save result of
  /// operations in [_results] but wll return it correctly
  ///
  /// if [returnWithOlderResults] is true values of [_results] will be attached
  /// to result of this run and will return both together
  ///
  /// this method is [Future] because commands from instructions are [FutureOr]
  /// it will await for all of them
  ///
  /// running commands wont run parallel and will run in sequence with await for
  /// each of them so you can use result of older commands to use in
  /// newer commands
  @Deprecated('no matter what use parsAndRunFromJson instead')
  Future<ResultTable> parsAndRunFromString(
    String query, {
    bool resetOldResultTable = false,
    bool storeResultOfThisRunInResultsTable = true,
    bool returnWithOlderResults = true,
  }) async {
    if (resetOldResultTable) {
      resetResultTable();
    }
    final internalResultTable = {..._results};
    final microQueries = query.split(';');
    for (final mq in microQueries) {
      var commandName = mq.split(' ')[0];
      var resultTag = commandName;
      if (commandName.isNotEmpty) {
        final hasTag = commandName.contains('#');
        if (hasTag) {
          resultTag = commandName.split('#')[1];
          commandName = commandName.split('#').first;
        }
        final relatedCommand = commands[commandName];
        final paramsStrings = mq.split(' ').sublist(1);
        final params = <String, ParamsModel>{};
        for (final ps in paramsStrings) {
          final param = ParamsModel.fromString(ps);
          params.addAll({param.name: param});
        }
        final result = await relatedCommand.run(params, internalResultTable);
        internalResultTable.addAll({resultTag: result});
      }
    }
    final output = internalResultTable;
    if (!returnWithOlderResults) {
      output.removeWhere((key, value) => _results[key] == value);
    }
    if (storeResultOfThisRunInResultsTable) {
      _results = internalResultTable;
    }
    return output;
  }

  /// run commands from a json data
  ///
  /// input example :
  ///
  /// ```json
  ///  [
  ///    {
  ///      "command": "DecorationGenerator",
  ///      "resultTag": "basic",
  ///      "params": [
  ///        {
  ///          "name": "color",
  ///          "value": "baseBack",
  ///          "isFromResults": true,
  ///        },
  ///        {
  ///          "name": "borderRadius",
  ///          "value": "15",
  ///        },
  ///        {
  ///          "name": "border",
  ///          "value": "0xFF34C517,2",
  ///        },
  ///      ],
  ///    }
  ///  ]
  /// ```
  ///
  /// if [resetOldResultTable] is true it will call [resetResultTable] before
  /// running any command
  ///
  /// if [storeResultOfThisRunInResultsTable] is false it wont save result of
  /// operations in [_results] but wll return it correctly
  ///
  /// if [returnWithOlderResults] is true values of [_results] will be attached
  /// to result of this run and will return both together
  ///
  /// this method is [Future] because commands from instructions are [FutureOr]
  /// it will await for all of them
  ///
  /// running commands wont run parallel and will run in sequence with await for
  /// each of them so you can use result of older commands to use in
  /// newer commands
  Future<ResultTable> parsAndRunFromJson(
    List<ResultTable> query, {
    bool resetOldResultTable = false,
    bool storeResultOfThisRunInResultsTable = true,
    bool returnWithOlderResults = true,
  }) async {
    if (resetOldResultTable) {
      resetResultTable();
    }
    final internalResultTable = {..._results};
    final queryCommands = query.map(CommandQueryModel.fromMap);
    for (final cmd in queryCommands) {
      if (commands.instructionsOperators.contains(cmd.command)) {
        final command = commands[cmd.command];
        final params = Map.fromEntries(
          cmd.params.map(
            (e) => MapEntry(
              e.name,
              e,
            ),
          ),
        );
        final result = await command.run(params, internalResultTable);
        internalResultTable.addAll({cmd.resultTag: result});
      } else {
        throw ErrorHandler('Command not found: ${cmd.command}', {
          ErrorType.variableError,
        });
      }
    }
    final output = internalResultTable;
    if (!returnWithOlderResults) {
      output.removeWhere((key, value) => _results[key] == value);
    }
    if (storeResultOfThisRunInResultsTable) {
      _results = internalResultTable;
    }
    return internalResultTable;
  }

  @override
  String toString() {
    return '''

Command Parser:
registered instructions: ${commands.instructionsOperators.join(', ')}
''';
  }
}

class CommandQueryModel {
  /// command name referenced to real command name in [InstructionSet]
  final String command;

  /// the key of value in results table
  final String resultTag;

  /// params of command
  final List<ParamsModel> params;

  const CommandQueryModel({
    required this.resultTag,
    required this.command,
    required this.params,
  });

  CommandQueryModel copyWith({
    String? command,
    String? resultTag,
    List<ParamsModel>? params,
  }) {
    return CommandQueryModel(
      command: command ?? this.command,
      resultTag: resultTag ?? command ?? this.command,
      params: params ?? this.params,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'command': command,
      'resultTag': resultTag,
      'params': params.map((x) => x.toMap()).toList(),
    };
  }

  factory CommandQueryModel.fromMap(Map<String, dynamic> map) {
    map.breakOnMissingKey(['command', 'params']);
    return CommandQueryModel(
      command: map['command'],
      resultTag: map['resultTag'] ?? map['command'],
      params: List.from(
        map['params'],
      )
          .map(
            (x) => ParamsModel.fromMap(
              Map<String, dynamic>.from(
                x,
              ),
            ),
          )
          .toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory CommandQueryModel.fromJson(
    String source,
  ) =>
      CommandQueryModel.fromMap(
        json.decode(source),
      );

  @override
  // ignore: lines_longer_than_80_chars
  String toString() => 'CommandQueryModel(command: $command, _resultTag: $resultTag, params: $params)';
}

/// [InstructionSet] is a class that contains all of the commands that can be
/// used in [CommandQueryParser] runs
class InstructionSet {
  final InstructionMap _instructions;
  final List<String> instructionsOperators;

  /// get list of [instructions] and create an instance based on it
  factory InstructionSet(
    List<CommandModel> instructions,
  ) {
    final instructionsMap = Map.fromEntries(
      instructions.map(
        (e) => MapEntry(
          e.command,
          e,
        ),
      ),
    );
    return InstructionSet._(instructionsMap, instructionsMap.keys.toList());
  }
  const InstructionSet._(this._instructions, this.instructionsOperators);

  CommandModel operator [](String other) {
    _instructions.breakOnMissingKey(<String>[other]);
    return _instructions[other]!;
  }
}
