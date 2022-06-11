import 'package:flutter/services.dart';
import 'package:hemend/debug/error_handler.dart';
import 'package:hemend/task_manager/isolate_manager/isolation_core.dart';
import 'package:rive/rive.dart';

abstract class RiveLoader {
  Future<RiveFile> fileLoader();
}

class RiveLoaderFromAsset extends RiveLoader {
  final String assetPath;
  final bool shouldCache;
  RiveFile? _cacheFile;
  RiveLoaderFromAsset({
    required this.assetPath,
    required this.shouldCache,
  });
  @override
  Future<RiveFile> fileLoader() async {
    if (_cacheFile != null) {
      return _cacheFile!;
    }
    final loaderResult = await _riveAssetLoader(assetPath);
    // await IsolationCore.createIsolateForSingleTask(
    //   task: _riveAssetLoader,
    //   taskParams: assetPath,
    // );
    // final result = loaderResult.singleActOnFinished(
    //   onDone: (data) => data!,
    //   onError: (error, stack) {
    //     throw error!;
    //   },
    // );
    if (shouldCache) {
      _cacheFile = loaderResult;
    }
    return loaderResult;
  }
}

Future<RiveFile> _riveAssetLoader(dynamic assetKey) async {
  if (assetKey is! String) {
    throw const ErrorHandler(
      'assetKey must be a String',
      {
        ErrorType.typeError,
      },
    );
  }
  final fileBytes = await rootBundle.load(
    assetKey,
  );
  return RiveFile.import(
    fileBytes,
  );
}
