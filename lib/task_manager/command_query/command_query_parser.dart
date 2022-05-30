import 'dart:convert' show json;

import '../../debug/error_handler.dart';
import '../../extensions/map_verification_tools.dart';
import 'command_query.dart' show CommandModel, ParamsModel, ResultTable;

///command runner will take instruction set named [commands]
///then can run command by using [parsAndRunFromString] or [parsAndRunFromJson]
class CommandQueryParser {
  final Map<String, CommandModel> commands;
  ResultTable _results = <String, dynamic>{};
  dynamic getResultOf(String key, {bool isRequired = true}) {
    if (!_results.containsKey(key) && isRequired) {
      throw ErrorHandler(
        'cannot find requested result from $key',
        <ErrorType>{
          ErrorType.variableError,
          ErrorType.notFound,
        },
      );
    }
    return _results[key];
  }

  void resetResultTable() {
    _results.clear();
    // _results = <String, dynamic>{};
  }

  CommandQueryParser({
    required this.commands,
  });
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
        if (relatedCommand != null) {
          final paramsStrings = mq.split(' ').sublist(1);
          final params = <String, ParamsModel>{};
          for (final ps in paramsStrings) {
            final param = ParamsModel.fromString(ps);
            params.addAll({param.name: param});
          }
          final result = await relatedCommand.run(params, internalResultTable);
          internalResultTable.addAll({resultTag: result});
        } else {
          throw ErrorHandler('Command not found: $commandName', {
            ErrorType.variableError,
          });
        }
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
      if (commands.keys.contains(cmd.command)) {
        final command = commands[cmd.command]!;
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
registered instructions: ${commands.keys.join(', ')}
''';
  }
}

class CommandQueryModel {
  final String command;
  final String resultTag;
  // String get resultTag => _resultTag ?? command;
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
