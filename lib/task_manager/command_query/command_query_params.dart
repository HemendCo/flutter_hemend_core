import 'dart:convert';

import '../../debug/error_handler.dart';

typedef Parameters = Map<String, ParamsModel>;

class ParamsModel {
  final String name;
  final String value;
  final bool isFromResults;
  const ParamsModel({
    required this.name,
    required this.value,
    required this.isFromResults,
  });
  factory ParamsModel.fromString(String element, Map<String, dynamic> results) {
    final split = element.split('=');
    final key = split[0];
    var value = split[1];
    final readFromResults = value.startsWith('|') && value.endsWith('|');
    if (readFromResults) {
      value = value.substring(1, value.length - 1);
      value = results[value].toString();
    }
    return ParamsModel(
      name: key,
      value: value,
      isFromResults: readFromResults,
    );
  }
  @override
  String toString() => ' $name = $value ';

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
    };
  }

  factory ParamsModel.fromMap(
    Map<String, dynamic> map,
  ) {
    if (![2, 3].contains(map.length) ||
        !map.containsKey(
          'name',
        ) ||
        !map.containsKey(
          'value',
        )) {
      throw ErrorHandler(
        '''

        cannot find forced fields on params map or found extra values
        given map is : $map''',
        {
          ErrorType.variableError,
        },
      );
    }
    final usingResults = map['isFromResults'] ?? false;

    return ParamsModel(
      name: map['name'],
      value: map['value'],
      isFromResults: usingResults,
    );
  }

  String toJson() => json.encode(toMap());

  factory ParamsModel.fromJson(
    String source,
  ) =>
      ParamsModel.fromMap(
        json.decode(source),
      );
}
