import 'dart:async';

import 'package:build/build.dart';
import 'package:dio/dio.dart' as dio;
import 'package:hemend/annotations/http_request/dio_requests.dart';
import 'package:source_gen/source_gen.dart';
import 'package:async/async.dart';
import '../model_visitor.dart';

class PostBuilder extends GeneratorForAnnotation<DioRequest> {
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    final values = <String>{};
    final annotations = library.annotatedWith(typeChecker);
    final classes = library.classes;

    values.add('//sample');

    /// e.displayName = className
    /// e.methods = get methods which have annotations as [#metadata]
    ///   if want to get data of annotation use [@computeConstantValue]
    ///   then use [@getField] like normal annotation to  get values of annotation
    ///
    ///
    values.addAll(
      classes.map(
        (e) {
          String result =
              '//don\'t create classes without annotation in this file ${e.metadata.isNotEmpty}';
          if (e.metadata.isNotEmpty) {
            result =
                '//${e.displayName} . ${e.methods.map((e) => e.metadata.map((e) => e.computeConstantValue()?.getField('baseUrl')?.toStringValue()))}';
          }
          return result;
        },
      ),
    );
    // for (var annotatedElement in annotations) {
    //   final generatedValue = generateForAnnotatedElement(
    //       annotatedElement.element, annotatedElement.annotation, buildStep);
    //   await for (var value in normalizeGeneratorOutput(generatedValue)) {
    //     assert(value.length == value.trim().length);
    //     values.add(value);
    //   }
    // }

    return values.join('\n\n');
  }

  @override
  String generateForAnnotatedElement(
      element, ConstantReader annotation, BuildStep buildStep) {
    final buffer = StringBuffer();
    // dio.Dio().post(fullPath,data: );

    final visitor = ModelVisitor();
    element.visitChildren(
        visitor); // Visits all the children of element in no particular order.

    final className = '${visitor.className}Gen'; // EX: 'ModelGen' for 'Model'.

    buildClass(buffer, annotation);

    return buffer.toString();
  }

  void buildClass(StringBuffer buffer, ConstantReader annotation) {
    buildPost(buffer, annotation);
  }

  void buildPost(StringBuffer buffer, ConstantReader annotation) {
    final fullPath = annotation.read('baseUrl').stringValue +
        annotation.read('apiPath').stringValue;
    String requestType =
        annotation.read('request').typeValue.toString().replaceAll('*', '');
    String responseType =
        annotation.read('response').typeValue.toString().replaceAll('*', '');
    buffer.writeln('''
Future<$responseType?> post($requestType body,
    [Map<String, dynamic> headers = const {}]) async {
  try {
    final result = await Dio().post('$fullPath',
        data: body.toMap(), options: Options(headers: headers));
    return $responseType.fromMap(result.data);
  } catch (e) {
    return null;
  }
}
''');
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

/// Converts [Future], [Iterable], and [Stream] implementations
/// containing [String] to a single [Stream] while ensuring all thrown
/// exceptions are forwarded through the return value.
Stream<String> normalizeGeneratorOutput(Object? value) {
  if (value == null) {
    return const Stream.empty();
  } else if (value is Future) {
    return StreamCompleter.fromFuture(value.then(normalizeGeneratorOutput));
  } else if (value is String) {
    value = [value];
  }

  if (value is Iterable) {
    value = Stream.fromIterable(value);
  }

  if (value is Stream) {
    return value.where((e) => e != null).map((e) {
      if (e is String) {
        return e.trim();
      }

      throw _argError(e as Object);
    }).where((e) => e.isNotEmpty);
  }
  throw _argError(value);
}

ArgumentError _argError(Object value) => ArgumentError(
    'Must be a String or be an Iterable/Stream containing String values. '
    'Found `${Error.safeToString(value)}` (${value.runtimeType}).');
