import 'dart:convert';

import '../../debug/error_handler.dart';
import '../../extensions/map_verification_tools.dart';

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

      ///the reason is that the value is from results
      ///but we set value from results here
      ///and this flag will active command runners value parser to replace
      ///results[value] with the real value
      ///like what we did here so it will be false but in [fromMap()]
      ///we don't have access to results and command runner will do the job
      isFromResults: false,
    );
  }
  @override
  String toString() => ' $name = $value ';

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
      'isFromResults': isFromResults,
    };
  }

  factory ParamsModel.fromMap(
    Map<String, dynamic> map,
  ) {
    map
      ..killOnMissingKey(['name', 'value'])
      ..killOnLengthMissMatch([2, 3]);
    // if (!map.verifyLength([2, 3]) ||
    //     !map.containsKey(
    //       'name',
    //     ) ||
    //     !map.containsKey(
    //       'value',
    //     )) {
    //   throw ErrorHandler(
    //     '''

    //     cannot find forced fields on params map or found extra values
    //     given map is : $map''',
    //     {
    //       ErrorType.variableError,
    //     },
    //   );
    // }
    return ParamsModel(
      name: map['name'],
      value: map['value'],
      isFromResults: map['isFromResults'] ?? false,
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
