import 'package:hemend/annotations/http_request/dio_requests.dart';

@DioRequest()
class Test {
  @DioRequest(
      name: "Test1",
      baseUrl: 'http://localhost:8080',
      apiPath: "/test",
      request: SampleRequest,
      response: SampleResponse)
  void testRequest() {}

  @DioRequest(
    name: "Test2",
    baseUrl: 'http://localhost:8080',
  )
  void testRequest2() {}
}

class SampleResponse extends ParsableObject {
  SampleResponse.fromMap(Map<String, dynamic> map) : super.fromMap(map);

  @override
  Map<String, dynamic> toMap() {
    throw UnimplementedError();
  }
}

class SampleRequest extends ParsableObject {
  SampleRequest.fromMap(Map<String, dynamic> map) : super.fromMap(map);

  @override
  Map<String, dynamic> toMap() {
    throw UnimplementedError();
  }
}
