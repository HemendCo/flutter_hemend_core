import 'package:build/build.dart';
import 'package:hemend/builders/http_request_generators/post_builder.dart';
import 'package:source_gen/source_gen.dart';

Builder generatePostMethod(BuilderOptions options) =>
    SharedPartBuilder([PostBuilder()], 'post_builder');
