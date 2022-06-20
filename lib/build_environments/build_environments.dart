// ignore_for_file: do_not_use_environment, constant_identifier_names

abstract class BuildEnvironments {
  static const int BUILD_TIME = int.fromEnvironment(
    'BUILD_TIME',
  );
  static DateTime get BUILD_DATE_TIME => DateTime.fromMillisecondsSinceEpoch(
        BUILD_TIME * 1000,
      );

  static const String LAST_GIT_COMMIT = String.fromEnvironment(
    'LAST_GIT_COMMIT',
  );
  static const String RELEASE_MODE = String.fromEnvironment(
    'RELEASE_MODE',
  );
  static BuildType get BUILD_TYPE => BuildType.fromString(RELEASE_MODE);
  static const int DEBUG_LEVEL = int.fromEnvironment(
    'DEBUG_LEVEL',
  );
  static const String CRASHLYTIX_APP_SECRET = String.fromEnvironment(
    'CONFIG_CRASHLYTIX_APP_SECRET',
  );
  static const String CRASHLYTIX_APP_ID = String.fromEnvironment(
    'CONFIG_CRASHLYTIX_APP_ID',
  );
  static const String CRASHLYTIX_SERVER_ADDRESS = String.fromEnvironment(
    'CONFIG_CRASHLYTIX_SERVER_ADDRESS',
  );
  static Map<String, dynamic> toMap() {
    return {
      'BUILD_TIME': BUILD_TIME,
      'BUILD_DATE_TIME': BUILD_DATE_TIME.toIso8601String(),
      'LAST_GIT_COMMIT': LAST_GIT_COMMIT,
      'RELEASE_MODE': RELEASE_MODE,
      'BUILD_TYPE': BUILD_TYPE,
      'DEBUG_LEVEL': DEBUG_LEVEL,
      'CRASHLYTIX_APP_SECRET': CRASHLYTIX_APP_SECRET,
      'CRASHLYTIX_APP_ID': CRASHLYTIX_APP_ID,
      'CRASHLYTIX_SERVER_ADDRESS': CRASHLYTIX_SERVER_ADDRESS,
    };
  }
}

enum BuildType {
  release(
    environmentParams: {
      'RELEASE_MODE': 'RELEASE',
      'DEBUG_LEVEL': '0',
    },
  ),
  debug(
    environmentParams: {
      'RELEASE_MODE': 'DEBUG',
      'DEBUG_LEVEL': '1',
    },
  ),
  profile(
    environmentParams: {
      'RELEASE_MODE': 'PROFILE',
      'DEBUG_LEVEL': '0',
    },
  ),
  debugBuild(
    buildParams: [
      '--debug',
    ],
    environmentParams: {
      'RELEASE_MODE': 'DEBUG',
      'DEBUG_LEVEL': '1',
    },
  ),
  performance(
    buildParams: [
      '--profile',
    ],
    environmentParams: {
      'RELEASE_MODE': 'PERFORMANCE',
      'DEBUG_LEVEL': '2',
    },
  ),
  presentation(
    environmentParams: {
      'RELEASE_MODE': 'PRESENTATION',
      'DEBUG_LEVEL': '1',
    },
  );

  const BuildType({
    this.buildParams = const [],
    required this.environmentParams,
  });
  factory BuildType.byIndex(int index) => values[index];
  factory BuildType.fromString(
    String name,
  ) =>
      values.firstWhere(
        (element) => element.name == name.toLowerCase(),
      );

  final List<String> buildParams;
  final Map<String, String> environmentParams;
}
