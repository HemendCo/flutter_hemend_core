// ignore_for_file: do_not_use_environment, constant_identifier_names, lines_longer_than_80_chars

import '../generated_env.dart';

abstract class BuildEnvironments {
  static DateTime get BUILD_DATE_TIME_OBJECT => DateTime.fromMillisecondsSinceEpoch(
        $Environments.BUILD_DATE_TIME * 1000,
      );
  static BuildType get BUILD_TYPE => BuildType.fromString($Environments.HEMEND_CONFIG_RELEASE_MODE);

  static Map<String, dynamic> toMap() {
    return {
      'BUILD_DATE_TIME': $Environments.BUILD_DATE_TIME,
      'BUILD_DATE_TIME_ISO': $Environments.BUILD_DATE_TIME_ISO,
      'BUILD_DATE_TIME_YEAR': $Environments.BUILD_DATE_TIME_YEAR,
      'BUILD_DATE_TIME_MONTH': $Environments.BUILD_DATE_TIME_MONTH,
      'BUILD_DATE_TIME_DAY': $Environments.BUILD_DATE_TIME_DAY,
      'BUILD_DATE_TIME_HOUR': $Environments.BUILD_DATE_TIME_HOUR,
      'BUILD_DATE_TIME_MINUTE': $Environments.BUILD_DATE_TIME_MINUTE,
      'BUILD_DATE_TIME_SECOND': $Environments.BUILD_DATE_TIME_SECOND,
      'HEMEND_CONFIG_IS_FORCED': $Environments.HEMEND_CONFIG_IS_FORCED,
      'HEMEND_CONFIG_BUILD_MODE': $Environments.HEMEND_CONFIG_BUILD_MODE,
      'HEMEND_CONFIG_RELEASE_MODE': $Environments.HEMEND_CONFIG_RELEASE_MODE,
      'HEMEND_CONFIG_DEBUG_LEVEL': $Environments.HEMEND_CONFIG_DEBUG_LEVEL,
      'HEMEND_CONFIG_BUILD_PLATFORM': $Environments.HEMEND_CONFIG_BUILD_PLATFORM,
      'LAST_COMMIT_HASH': $Environments.LAST_COMMIT_HASH,
      'LAST_COMMIT_AUTHOR_EMAIL': $Environments.LAST_COMMIT_AUTHOR_EMAIL,
      'LAST_COMMIT_DATE_TIME': $Environments.LAST_COMMIT_DATE_TIME,
      'HEMEND_CONFIG_UPLOAD_API': $Environments.HEMEND_CONFIG_UPLOAD_API,
      'HEMEND_CONFIG_UPLOAD_PATH': $Environments.HEMEND_CONFIG_UPLOAD_PATH,
      'HEMEND_CONFIG_NAME_FORMAT': $Environments.HEMEND_CONFIG_NAME_FORMAT,
      'HEMEND_CONFIG_CLI_VERSION': $Environments.HEMEND_CONFIG_CLI_VERSION,
      'CONFIG_CRASHLYTIX_APP_SECRET': $Environments.CONFIG_CRASHLYTIX_APP_SECRET,
      'CONFIG_CRASHLYTIX_APP_ID': $Environments.CONFIG_CRASHLYTIX_APP_ID,
      'CONFIG_CRASHLYTIX_SERVER_ADDRESS': $Environments.CONFIG_CRASHLYTIX_SERVER_ADDRESS,
      'APP_CONFIG_NAME': $Environments.APP_CONFIG_NAME,
      'APP_CONFIG_VERSION': $Environments.APP_CONFIG_VERSION
    };
  }
}

enum BuildType {
  release(
    environmentParams: {
      'HEMEND_CONFIG_RELEASE_MODE': 'RELEASE',
      'HEMEND_CONFIG_DEBUG_LEVEL': '0',
    },
  ),
  debug(
    environmentParams: {
      'HEMEND_CONFIG_RELEASE_MODE': 'DEBUG',
      'HEMEND_CONFIG_DEBUG_LEVEL': '1',
    },
  ),
  profile(
    environmentParams: {
      'HEMEND_CONFIG_RELEASE_MODE': 'PROFILE',
      'HEMEND_CONFIG_DEBUG_LEVEL': '0',
    },
  ),
  debugBuild(
    buildParams: [
      '--debug',
    ],
    environmentParams: {
      'HEMEND_CONFIG_RELEASE_MODE': 'DEBUG',
      'HEMEND_CONFIG_DEBUG_LEVEL': '1',
    },
  ),
  performance(
    buildParams: [
      '--profile',
    ],
    environmentParams: {
      'HEMEND_CONFIG_RELEASE_MODE': 'PERFORMANCE',
      'HEMEND_CONFIG_DEBUG_LEVEL': '2',
    },
  ),
  presentation(
    environmentParams: {
      'HEMEND_CONFIG_RELEASE_MODE': 'PRESENTATION',
      'HEMEND_CONFIG_DEBUG_LEVEL': '1',
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
  Map<String, dynamic> toMap() => {
        'type': name,
        'buildParams': buildParams,
        'environmentParams': environmentParams,
      };

  final List<String> buildParams;
  final Map<String, String> environmentParams;
}
