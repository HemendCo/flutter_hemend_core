import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'http_request_generators/post_builder.dart';

Builder generatePostMethod(BuilderOptions options) => LibraryBuilder(
      PostBuilder(),
      generatedExtension: '.hemend.dart',
      header: '''library hemend.generated_library.dio_handler; 
        import 'package:hemend/annotations/http_request/dio_requests.dart';
        import 'package:hemend/external_libraries/http_requests/dio.dart';
        import 'models.dart';
          ''',
    );
