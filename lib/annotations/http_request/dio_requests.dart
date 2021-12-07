class DioRequest {
  final String name;
  final String baseUrl;
  final String apiPath;
  final Type request;
  final Type response;

  const DioRequest({
    required this.name,
    required this.baseUrl,
    this.apiPath = '',
    this.request = NullParsableObject,
    this.response = NullParsableObject,
  });

  @override
  String toString() {
    // TODO: implement toString
    return '@DioRequest($name,$baseUrl,$apiPath)';
  }
}

enum RequestType { post, get }

abstract class ParsableObject {
  ParsableObject.fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap();
}

class NullParsableObject implements ParsableObject {
  NullParsableObject();
  factory NullParsableObject.fromMap(Map<String, dynamic> map) =>
      NullParsableObject();

  @override
  Map<String, dynamic> toMap() {
    return {};
  }
}
