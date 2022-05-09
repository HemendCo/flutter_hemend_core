import 'dart:convert';

typedef Parameters = Map<String, ParamsModel>;

class ParamsModel {
  final String name;
  final String value;
  const ParamsModel({
    required this.name,
    required this.value,
  });
  factory ParamsModel.fromString(String element, Map<String, dynamic> results) {
    final split = element.split('=');
    final key = split[0];
    var value = split[1];

    if (value.startsWith('|') && value.endsWith('|')) {
      value = value.substring(1, value.length - 1);
      value = results[value].toString();
    }
    return ParamsModel(name: key, value: value);
  }
  @override
  String toString() => ' $name = $value ';

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
    };
  }

  factory ParamsModel.fromMap(Map<String, dynamic> map) {
    return ParamsModel(
      name: map['name'] ?? '',
      value: map['value'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ParamsModel.fromJson(String source) => ParamsModel.fromMap(
        json.decode(source),
      );
}
