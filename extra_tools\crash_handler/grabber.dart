// TODO(Motalleb): change base from string file to json file from database
///** its an application on pure dart code
///** use Dart grabber.dart to run
///** set [kCrashLogUrl] to crash log url
///** currently supports text file appended with crash-logs line by line
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

///**Set url before using this app
const kCrashLogUrl = '';

String convertingEpochToDate(dynamic epoch) {
  final time = int.parse(epoch.toString());
  final baseDateTime = DateTime.fromMillisecondsSinceEpoch(time);
  final finalDateTime = DateTime(
    baseDateTime.year,
    baseDateTime.month,
    baseDateTime.day,
    baseDateTime.hour,
  );
  return '${finalDateTime.millisecondsSinceEpoch ~/ 1000}';
}

Iterable<Map<String, dynamic>> collectExceptionsOnly(
  final Iterable<Map<String, dynamic>> input,
) {
  final exceptions = input.map(
    (e) => Map<String, dynamic>.from(
      {
        'exception': e['exception'],
        'stacktrace': e['stacktrace'],
      },
    ),
  );
  return exceptions;
}

Future<void> deObfuscationPhase() async {
  print('starting deobfuscation phase');

  ///get all files in directory
  final foundFiles = await Directory('./').list().map((e) => e.path).toList();

  ///select debugSymbol files
  final debugSymbols = foundFiles.where(
    (element) => element.endsWith('.symbols'),
  );

  print('found debug symbols: $debugSymbols');

  for (final ds in debugSymbols) {
    print('deobfuscation phase started using $ds');

    ///take all json files in directory
    final jsonFiles = foundFiles.where((element) => element.endsWith('json'));

    ///placeholder for output files
    final outputs = <String>[];
    for (final file in jsonFiles) {
      // print(file.path);
      outputs.add('$file-deobfuscated.temp');

      await Process.run(
        'flutter',
        [
          ///passing the parameter to identify its deObfuscation
          'symbolize',

          ///passing the symbols file
          '-d',
          ds,

          ///passing the obfuscated file
          '-i',
          file,

          ///selecting output file
          '-o',
          '$file-deobfuscated.temp',
        ],
      );
    }

    ///delete old json files
    for (final file in jsonFiles) {
      File(file).deleteSync();
    }

    ///replace deObfuscated files with original files
    for (final file in outputs) {
      File(file).renameSync(file.replaceAll('-deobfuscated.temp', ''));
    }
  }
}

void main() async {
  print('gettingData from server');

  ///downloading data from server
  final crashLogString = (await http.get(
    Uri.parse(kCrashLogUrl),
  ))
      .body
      .replaceAll(
        '\\n',
        ' |NextLine| ',
      );

  print('gotData from server now start parsing data');

  ///converting string data to json
  final crashLogList = crashLogString
      .split('\n')
      .where(
        (element) => element.isNotEmpty,
      )
      .map((e) {
    return Map<String, dynamic>.from(jsonDecode(e));
  }).toList();

  print(
    '''<--->
done parsing with ${crashLogList.length} items
now trying to map with crash time and device id
and store them in a file based on crash time (one per hour)
<--->''',
  );

  ///List of All exceptions without extra info about device nor application info
  ///and store them separately in another file
  final exceptionList = collectExceptionsOnly(crashLogList);
  File(
    'all_exceptions.json',
  ).writeAsStringSync(
    jsonEncode(
      exceptionList,
    ).replaceAll(
      ' |NextLine| ',
      '\n',
    ),
  );

  final resultMap = crashLogList
      .mapBy(
        propertyName: 'errorTime',
        keySelector: convertingEpochToDate,
      )
      .map(
        (key, value) => MapEntry(
          key,
          value.mapBy(
            propertyName: 'deviceInfo',
            removeAfterMap: true,
            // ignore: avoid_dynamic_calls
            keySelector: (element) => element['id'] ?? 'No Device Found',
          ),
        ),
      );

  ///Store crash logs in files based on crash time (one per hour)
  for (final crashByDate in resultMap.entries) {
    final converted = jsonEncode(crashByDate.value).replaceAll(
      ' |NextLine| ',
      '\n',
    );
    print('writing into file ${crashByDate.key}');
    File('${crashByDate.key}.json').writeAsStringSync(converted);
  }
  print('done writing all files');

  ///Final phase is to deObfuscate the files
  await deObfuscationPhase();
  print('done');
}

extension MappingTools<K, V, T extends Map<K, V>> on Iterable<T> {
  Map<dynamic, Iterable<Map<K, V>>> mapBy({
    required K propertyName,
    bool removeAfterMap = false,
    dynamic Function(V element)? keySelector,
  }) {
    final result = <dynamic, Iterable<Map<K, V>>>{};
    keySelector ??= (element) => element;
    for (final i in this) {
      final key = keySelector(i[propertyName]!);
      if (removeAfterMap) {
        i.removeWhere((key, value) => key == propertyName);
      }
      if (!result.containsKey(key)) {
        result[key] = [i];
      } else if (result.containsKey(key)) {
        result[key] = [...result[key]!, i];
      }
    }
    return result;
  }
}
