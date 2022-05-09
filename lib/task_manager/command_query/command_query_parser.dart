import 'dart:convert';

import '../../debug/error_handler.dart';

import 'command_query_command.dart';
import 'command_query_params.dart';

class CommandQueryParser {
  final Map<String, CommandModel> commands;
  CommandQueryParser({
    required this.commands,
  });
  Future<Map<String, dynamic>> parsAndRunFromString(String query) async {
    final results = <String, dynamic>{};
    final microQueries = query.split(';');
    for (final mq in microQueries) {
      // TODO(FMotalleb): replace with new parser;
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
            final param = ParamsModel.fromString(ps, results);
            params.addAll({param.name: param});
          }
          final result = await relatedCommand.run(params, results);
          results.addAll({resultTag: result});
        } else {
          throw ErrorHandler('Command not found: $commandName', {
            ErrorType.variableError,
          });
        }
      }
    }
    return results;
  }

  Future<Map<String, dynamic>> parsAndRunFromJson(
    List<Map<String, dynamic>> query,
  ) async {
    final results = <String, dynamic>{};
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
        final result = await command.run(params, results);
        results.addAll({cmd.resultTag: result});
      } else {
        throw ErrorHandler('Command not found: ${cmd.command}', {
          ErrorType.variableError,
        });
      }
    }
    return results;
  }
}

class CommandQueryModel {
  final String command;
  final String? _resultTag;
  String get resultTag => _resultTag ?? command;
  final List<ParamsModel> params;
  const CommandQueryModel({
    String? resultTag,
    required this.command,
    required this.params,
  }) : _resultTag = resultTag;

  CommandQueryModel copyWith({
    String? command,
    String? resultTag,
    List<ParamsModel>? params,
  }) {
    return CommandQueryModel(
      command: command ?? this.command,
      resultTag: resultTag ?? _resultTag,
      params: params ?? this.params,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'command': command,
      '_resultTag': _resultTag,
      'params': params.map((x) => x.toMap()).toList(),
    };
  }

  factory CommandQueryModel.fromMap(Map<String, dynamic> map) {
    return CommandQueryModel(
      command: map['command'] ?? '',
      resultTag: map['resultTag'],
      params: List.from(
        List.from(
          map['params'] ?? [],
        ).map(
          // ignore: unnecessary_lambdas
          (x) => ParamsModel.fromMap(x),
        ),
      ),
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
  String toString() => 'CommandQueryModel(command: $command, _resultTag: $_resultTag, params: $params)';
}
