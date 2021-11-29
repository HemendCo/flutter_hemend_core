class DioRequest<RequestType extends ParsableObject,
    ResponseType extends ParsableObject> {
  final String baseUrl;
  final String apiPath;
  const DioRequest(this.baseUrl, this.apiPath);
}

enum RequestType { post, get }

abstract class ParsableObject {
  Map<String, dynamic> toMap();
}

class NullParsableObject implements ParsableObject {
  NullParsableObject();
  factory NullParsableObject.fromMap() => NullParsableObject();

  @override
  Map<String, dynamic> toMap() {
    return {};
  }
}
