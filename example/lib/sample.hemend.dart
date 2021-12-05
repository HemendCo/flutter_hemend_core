library hemend.generated_library.dio_handler;

import 'package:hemend/annotations/http_request/dio_requests.dart';
import 'package:hemend/external_libraries/http_requests/dio.dart';
import 'models.dart';

// **************************************************************************
// Generator: PostBuilder
// **************************************************************************

Future<SampleResponse?> post(SampleRequest body,
    [Map<String, dynamic> headers = const {}]) async {
  try {
    final result = await Dio().post('http://localhost:8080/test',
        data: body.toMap(), options: Options(headers: headers));
    return SampleResponse.fromMap(result.data);
  } catch (e) {
    return null;
  }
}

Future<NullParsableObject?> post(NullParsableObject body,
    [Map<String, dynamic> headers = const {}]) async {
  try {
    final result = await Dio().post('http://localhost:8080',
        data: body.toMap(), options: Options(headers: headers));
    return NullParsableObject.fromMap(result.data);
  } catch (e) {
    return null;
  }
}
