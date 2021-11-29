import 'package:build/build.dart';
import 'package:dio/dio.dart' as dio;
import 'package:hemend/annotations/http_request/dio_requests.dart';
import 'package:source_gen/source_gen.dart';

import '../model_visitor.dart';

class PostBuilder extends GeneratorForAnnotation<DioRequest> {
  // 1
  @override
  String generateForAnnotatedElement(
      element, ConstantReader annotation, BuildStep buildStep) {
    // 2
    final visitor = ModelVisitor();
    element.visitChildren(
        visitor); // Visits all the children of element in no particular order.

    // 3
    final className = '${visitor.className}Gen'; // EX: 'ModelGen' for 'Model'.

    // 4

    final buffer = StringBuffer();
    buffer.writeln('//' +
        annotation.read('baseUrl').stringValue +
        annotation.read('apiPath').stringValue);
    //dio.Dio().get(path)
    return buffer.toString();
  }

  void generateGettersAndSetters(
      ModelVisitor visitor, StringBuffer classBuffer) {
    // 1
    for (final field in visitor.fields.keys) {
      // 2
      final variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;

      // 3
      classBuffer.writeln(
          "${visitor.fields[field]} get $variable => variables['$variable'];");
      // EX: String get name => variables['name'];

      // 4
      classBuffer
          .writeln('set $variable(${visitor.fields[field]} $variable) {');
      classBuffer.writeln('super.$field = $variable;');
      classBuffer.writeln("variables['$variable'] = $variable;");
      classBuffer.writeln('}');

      // EX: set name(String name) {
      //       super._name = name;
      //       variables['name'] = name;
      //     }
    }
  }
}
