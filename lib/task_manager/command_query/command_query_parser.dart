import 'package:hemend/debug/error_handler.dart';

import 'command_query_command.dart';
import 'command_query_params.dart';

class CommandQueryParser {
  final Map<String, CommandModel> commands;
  CommandQueryParser({
    required this.commands,
  });
  Map<String, dynamic> parsAndRun(String query) {
    Map<String, dynamic> results = {};
    final microQueries = query.split(';');
    for (final mq in microQueries) {
      String commandName = mq.split(' ')[0]; //TODO replace with new parser;
      String resultTag = commandName;
      if (commandName.isNotEmpty) {
        final hasTag = commandName.contains('#');

        if (hasTag) {
          resultTag = commandName.split('#')[1];
          commandName = commandName.split('#').first;
        }
        final relatedCommand = commands[commandName];
        if (relatedCommand != null) {
          final paramsStrings = mq.split(' ').sublist(1);
          Parameters params = {};
          for (final ps in paramsStrings) {
            final param = ParamsModel.fromString(ps, results);
            params.addAll({param.name: param});
          }
          final result = relatedCommand.call(params, results);
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
}
