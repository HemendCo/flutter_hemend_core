import 'package:hemend/annotations/http_request/dio_requests.dart';

part 'sample.g.dart';

@DioRequest<NullParsableObject, NullParsableObject>(
  'http://localhost:8080',
  "/test",
)
void testRequest() {}
