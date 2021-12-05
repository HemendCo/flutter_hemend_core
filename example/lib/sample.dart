import 'package:hemend/annotations/http_request/dio_requests.dart';

import 'package:hemend/external_libraries/http_requests/dio.dart';

@DioRequest(
    name: "Test1",
    baseUrl: 'http://localhost:8080',
    apiPath: "/test",
    request: SampleRequest,
    response: SampleResponse)
void testRequest() {
  Object d = {'asf': 'asf'};
}

@DioRequest(
  name: "Test2",
  baseUrl: 'http://localhost:8080',
)
void testRequest2() {
  Object d = {'asf': 'asf'};
}

class SampleResponse extends ParsableObject {
  SampleResponse.fromMap(Map<String, dynamic> map) : super.fromMap(map);

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    throw UnimplementedError();
  }
}

class SampleRequest extends ParsableObject {
  SampleRequest.fromMap(Map<String, dynamic> map) : super.fromMap(map);

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    throw UnimplementedError();
  }
}
