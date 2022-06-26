// ignore_for_file: constant_identifier_names, do_not_use_environment, lines_longer_than_80_chars

abstract class $Environments {
  $Environments._();
  static const BUILD_DATE_TIME = int.fromEnvironment('BUILD_DATE_TIME');
  static const BUILD_DATE_TIME_ISO = String.fromEnvironment('BUILD_DATE_TIME_ISO');
  static const BUILD_DATE_TIME_YEAR = int.fromEnvironment('BUILD_DATE_TIME_YEAR');
  static const BUILD_DATE_TIME_MONTH = int.fromEnvironment('BUILD_DATE_TIME_MONTH');
  static const BUILD_DATE_TIME_DAY = int.fromEnvironment('BUILD_DATE_TIME_DAY');
  static const BUILD_DATE_TIME_HOUR = int.fromEnvironment('BUILD_DATE_TIME_HOUR');
  static const BUILD_DATE_TIME_MINUTE = int.fromEnvironment('BUILD_DATE_TIME_MINUTE');
  static const BUILD_DATE_TIME_SECOND = int.fromEnvironment('BUILD_DATE_TIME_SECOND');
  static const IS_FORCED = bool.fromEnvironment('IS_FORCED');
  static const BUILD_MODE = String.fromEnvironment('BUILD_MODE');
  static const RELEASE_MODE = String.fromEnvironment('RELEASE_MODE');
  static const DEBUG_LEVEL = int.fromEnvironment('DEBUG_LEVEL');
  static const PLATFORM = String.fromEnvironment('PLATFORM');
  static const LAST_COMMIT_HASH = String.fromEnvironment('LAST_COMMIT_HASH');
  static const LAST_COMMIT_AUTHOR_EMAIL = String.fromEnvironment('LAST_COMMIT_AUTHOR_EMAIL');
  static const LAST_COMMIT_DATE_TIME = int.fromEnvironment('LAST_COMMIT_DATE_TIME');
  static const ENV_CONFIG_API_VERSION = int.fromEnvironment('ENV_CONFIG_API_VERSION');
  static const ENV_CONFIG_API_SUFFIX = String.fromEnvironment('ENV_CONFIG_API_SUFFIX');
  static const HEMEND_CONFIG_UPLOAD_API = String.fromEnvironment('HEMEND_CONFIG_UPLOAD_API');
  static const HEMEND_CONFIG_UPLOAD_PATH = String.fromEnvironment('HEMEND_CONFIG_UPLOAD_PATH');
  static const HEMEND_CONFIG_NAME_FORMAT = String.fromEnvironment('HEMEND_CONFIG_NAME_FORMAT');
  static const HEMEND_CONFIG_CLI_VERSION = String.fromEnvironment('HEMEND_CONFIG_CLI_VERSION');
  static const CONFIG_APP_API_BASE = String.fromEnvironment('CONFIG_APP_API_BASE');
  static const CONFIG_APP_API_VERSION = int.fromEnvironment('CONFIG_APP_API_VERSION');
  static const CONFIG_CRASHLYTIX_APP_SECRET = String.fromEnvironment('CONFIG_CRASHLYTIX_APP_SECRET');
  static const CONFIG_CRASHLYTIX_APP_ID = String.fromEnvironment('CONFIG_CRASHLYTIX_APP_ID');
  static const CONFIG_CRASHLYTIX_SERVER_ADDRESS = String.fromEnvironment('CONFIG_CRASHLYTIX_SERVER_ADDRESS');
  static const APP_CONFIG_NAME = String.fromEnvironment('APP_CONFIG_NAME');
  static const APP_CONFIG_VERSION = String.fromEnvironment('APP_CONFIG_VERSION');
  static Map<String, dynamic> toMap() {
    return {
      'BUILD_DATE_TIME': BUILD_DATE_TIME,
      'BUILD_DATE_TIME_ISO': BUILD_DATE_TIME_ISO,
      'BUILD_DATE_TIME_YEAR': BUILD_DATE_TIME_YEAR,
      'BUILD_DATE_TIME_MONTH': BUILD_DATE_TIME_MONTH,
      'BUILD_DATE_TIME_DAY': BUILD_DATE_TIME_DAY,
      'BUILD_DATE_TIME_HOUR': BUILD_DATE_TIME_HOUR,
      'BUILD_DATE_TIME_MINUTE': BUILD_DATE_TIME_MINUTE,
      'BUILD_DATE_TIME_SECOND': BUILD_DATE_TIME_SECOND,
      'IS_FORCED': IS_FORCED,
      'BUILD_MODE': BUILD_MODE,
      'RELEASE_MODE': RELEASE_MODE,
      'DEBUG_LEVEL': DEBUG_LEVEL,
      'PLATFORM': PLATFORM,
      'LAST_COMMIT_HASH': LAST_COMMIT_HASH,
      'LAST_COMMIT_AUTHOR_EMAIL': LAST_COMMIT_AUTHOR_EMAIL,
      'LAST_COMMIT_DATE_TIME': LAST_COMMIT_DATE_TIME,
      'ENV_CONFIG_API_VERSION': ENV_CONFIG_API_VERSION,
      'ENV_CONFIG_API_SUFFIX': ENV_CONFIG_API_SUFFIX,
      'HEMEND_CONFIG_UPLOAD_API': HEMEND_CONFIG_UPLOAD_API,
      'HEMEND_CONFIG_UPLOAD_PATH': HEMEND_CONFIG_UPLOAD_PATH,
      'HEMEND_CONFIG_NAME_FORMAT': HEMEND_CONFIG_NAME_FORMAT,
      'HEMEND_CONFIG_CLI_VERSION': HEMEND_CONFIG_CLI_VERSION,
      'CONFIG_APP_API_BASE': CONFIG_APP_API_BASE,
      'CONFIG_APP_API_VERSION': CONFIG_APP_API_VERSION,
      'CONFIG_CRASHLYTIX_APP_SECRET': CONFIG_CRASHLYTIX_APP_SECRET,
      'CONFIG_CRASHLYTIX_APP_ID': CONFIG_CRASHLYTIX_APP_ID,
      'CONFIG_CRASHLYTIX_SERVER_ADDRESS': CONFIG_CRASHLYTIX_SERVER_ADDRESS,
      'APP_CONFIG_NAME': APP_CONFIG_NAME,
      'APP_CONFIG_VERSION': APP_CONFIG_VERSION
    };
  }
}
