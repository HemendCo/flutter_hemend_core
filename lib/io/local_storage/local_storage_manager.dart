import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract class LocalStorageManager {
  //disable ability to create instances of Manager
  LocalStorageManager._();

  static Future<File> write(
      {required String fileName, List<int> data = const []}) async {
    final fileInstance = await read(fileName);
    final finalFile = await fileInstance.writeAsBytes(data);
    return finalFile;
  }

  static Future<File> read(String fileName) async {
    final fileInstance = File(await getSavePath(fileName));
    return fileInstance;
  }

  static Future<String> getSavePath(String fileName) async {
    final directory = (await getApplicationDocumentsDirectory()).path;
    return '$directory/$fileName';
  }
}
