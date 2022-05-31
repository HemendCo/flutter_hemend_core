import 'dart:convert' show json;

import '../../debug/error_handler.dart';
import '../../extensions/list_verification_tools.dart';
import '../../extensions/map_verification_tools.dart';
import '../../extensions/type_caster/type_caster.dart';

typedef Parameters = Map<String, ParamsModel>;
typedef ResultTable = Map<String, dynamic>;

///code runner will receive its parameters as [String] they may have a flag
///to show its from result table or not if flag is true it will access its value
///from [ResultTable] and if flag is false it will use its value directly
///since its always from a [String] it need to be parsed to its real type
///for this purpose we will use a method called [StringValueParser] of type [T]
///it will have one [String] parameter (the value of parameter) and it will
///return [T] as the type of data we need
///
///example using [ParserMap] :
///
/// ```dart
///
/// Map<Type, ValueParser> mappers = {
///   String: ValueParser<String>(
///     toBaseCaster: (p0) => p0,
///     toDestinationCaster: (p0) => p0,
///   ),
///   double: ValueParser<double>(
///     toBaseCaster: (p0) => p0.toString(),
///     toDestinationCaster: (p0) => double.parse(p0),
///   ),
///   Color: ValueParser<Color>(
///     toBaseCaster: (p0) => p0.value.toString(),
///     toDestinationCaster: (p0) => Color(int.parse(p0)),
///   ),
/// };
/// ```
typedef StringValueParser<T> = TypeCaster<String, T>;
typedef ParserMap = Map<Type, StringValueParser<Type>>;

class ParamsModel {
  final String name;
  final String value;
  final bool isFromResults;
  const ParamsModel({
    required this.name,
    required this.value,
    required this.isFromResults,
  });

  /// extract value of params from [mappers] parser or [results] table
  /// it will throw errors if cant find parser or result table
  /// if [isFromResults] is true it will access its value from [results] table
  /// if [isFromResults] is false it will use its value directly and cast it
  /// to the type of [T] using [mappers] parser
  T extractValue<T>({
    required Map<Type, StringValueParser> mappers,
    required ResultTable results,
  }) {
    if (isFromResults) {
      return extractFromResultsTable<T>(results);
    } else {
      return extractValueUsingTypeMappers<T>(mappers);
    }
  }

  /// use mappers table to cast [value] to [T]
  /// will throw if mapper was not found
  /// for more information about parsers look at [StringValueParser]
  T extractValueUsingTypeMappers<T>(Map<Type, StringValueParser> mappers) {
    mappers.breakOnMissingKey([T]);
    return mappers[T]!.toDestinationCaster(value);
  }

  /// extract val
  T extractFromResultsTable<T>(ResultTable results) {
    results.breakOnMissingKey([value]);
    final referencedObject = results[value];

    /// checking if the value from result table has correct type in type cast
    if (referencedObject is! T) {
      throw ErrorHandler(
        '''

found result for $value but it is not of type $T
found type is ${referencedObject.runtimeType}
result table items: ${results.keys}''',
        <ErrorType>{
          ErrorType.variableError,
          ErrorType.notFound,
        },
      );
    }
    return referencedObject;
  }

  /// create a [ParamsModel] from a string like
  /// `name=value`
  ///
  /// if value is braced in tow `|` will set [isFromResults] to true
  /// like `name=|value|`
  ///
  /// in this case it will remove the `|` and set value to `value`
  factory ParamsModel.fromString(String element) {
    final split = element.split('=')
      ..breakOnLengthMismatch(
        [
          2,
        ],
      );
    final key = split[0];
    var value = split[1];
    final readFromResults = value.startsWith('|') && value.endsWith('|');
    if (readFromResults) {
      value = value.substring(1, value.length - 1);
    }
    return ParamsModel(
      name: key,
      value: value,
      isFromResults: readFromResults,
    );
  }
  @override
  String toString() => '$name=$value';

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
      ..breakOnMissingKey(['name', 'value'])
      ..breakOnLengthMissMatch([2, 3]);
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
