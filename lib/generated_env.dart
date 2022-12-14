// ignore_for_file: constant_identifier_names, do_not_use_environment, lines_longer_than_80_chars
abstract class $Environments {
  $Environments._();
  static const BUILD_DATE_TIME = int.fromEnvironment(
    'BUILD_DATE_TIME',
    defaultValue: 1656483600,
  );
  static const BUILD_DATE_TIME_ISO = String.fromEnvironment(
    'BUILD_DATE_TIME_ISO',
    defaultValue: '2022-06-29T10:50:00.260635',
  );
  static const BUILD_DATE_TIME_YEAR = int.fromEnvironment(
    'BUILD_DATE_TIME_YEAR',
    defaultValue: 2022,
  );
  static const BUILD_DATE_TIME_MONTH = int.fromEnvironment(
    'BUILD_DATE_TIME_MONTH',
    defaultValue: 6,
  );
  static const BUILD_DATE_TIME_DAY = int.fromEnvironment(
    'BUILD_DATE_TIME_DAY',
    defaultValue: 29,
  );
  static const BUILD_DATE_TIME_HOUR = int.fromEnvironment(
    'BUILD_DATE_TIME_HOUR',
    defaultValue: 10,
  );
  static const BUILD_DATE_TIME_MINUTE = int.fromEnvironment(
    'BUILD_DATE_TIME_MINUTE',
    defaultValue: 50,
  );
  static const BUILD_DATE_TIME_SECOND = int.fromEnvironment(
    'BUILD_DATE_TIME_SECOND',
    defaultValue: 0,
  );
  static const HEMEND_CONFIG_IS_FORCED = bool.fromEnvironment(
    'HEMEND_CONFIG_IS_FORCED',
    defaultValue: true,
  );
  static const HEMEND_CONFIG_BUILD_MODE = String.fromEnvironment(
    'HEMEND_CONFIG_BUILD_MODE',
    defaultValue: 'release',
  );
  static const HEMEND_CONFIG_RELEASE_MODE = String.fromEnvironment(
    'HEMEND_CONFIG_RELEASE_MODE',
    defaultValue: 'RELEASE',
  );
  static const HEMEND_CONFIG_DEBUG_LEVEL = int.fromEnvironment(
    'HEMEND_CONFIG_DEBUG_LEVEL',
    defaultValue: 0,
  );
  static const HEMEND_CONFIG_BUILD_PLATFORM = String.fromEnvironment(
    'HEMEND_CONFIG_BUILD_PLATFORM',
    defaultValue: 'android',
  );
  static const LAST_COMMIT_HASH = String.fromEnvironment(
    'LAST_COMMIT_HASH',
    defaultValue: '3a9edad59d35f7746d9125cb77acfbc7fbeae6e0',
  );
  static const LAST_COMMIT_AUTHOR_EMAIL = String.fromEnvironment(
    'LAST_COMMIT_AUTHOR_EMAIL',
    defaultValue: 'fmotalleb@gmail.com',
  );
  static const LAST_COMMIT_DATE_TIME = int.fromEnvironment(
    'LAST_COMMIT_DATE_TIME',
    defaultValue: 1656404766,
  );
  static const ENV_CONFIG_API_VERSION = int.fromEnvironment(
    'ENV_CONFIG_API_VERSION',
    defaultValue: 1,
  );
  static const ENV_CONFIG_API_SUFFIX = String.fromEnvironment(
    'ENV_CONFIG_API_SUFFIX',
    defaultValue: 'IF DEBUG_LEVEL >= 1 ? /demo : \$empStr',
  );
  static const ENV_CONFIG_RELEASE_TO = String.fromEnvironment(
    'ENV_CONFIG_RELEASE_TO',
    defaultValue: 'Building for android',
  );
  static const HEMEND_CONFIG_UPLOAD_API = String.fromEnvironment(
    'HEMEND_CONFIG_UPLOAD_API',
    defaultValue: 'http://94.101.184.89:8081',
  );
  static const HEMEND_CONFIG_UPLOAD_PATH = String.fromEnvironment(
    'HEMEND_CONFIG_UPLOAD_PATH',
    defaultValue: '/upload/outputs',
  );
  static const HEMEND_CONFIG_NAME_FORMAT = String.fromEnvironment(
    'HEMEND_CONFIG_NAME_FORMAT',
    defaultValue: '\$n%-\$v%-\$build_type%-\$YYYY%-\$MM%-\$DD%-\$HH%:\$mm%:\$ss%',
  );
  static const HEMEND_CONFIG_CLI_VERSION = String.fromEnvironment(
    'HEMEND_CONFIG_CLI_VERSION',
    defaultValue: '0.1',
  );
  static const CONFIG_APP_API_BASE = String.fromEnvironment(
    'CONFIG_APP_API_BASE',
    defaultValue: 'example.comIF DEBUG_LEVEL >= 1 ? /demo : \$empStr',
  );
  static const CONFIG_APP_API_VERSION = int.fromEnvironment(
    'CONFIG_APP_API_VERSION',
    defaultValue: 1,
  );
  static const CONFIG_CRASHLYTIX_APP_SECRET = String.fromEnvironment(
    'CONFIG_CRASHLYTIX_APP_SECRET',
    defaultValue: 'Add Crashlytix App Secret Here',
  );
  static const CONFIG_CRASHLYTIX_APP_ID = String.fromEnvironment(
    'CONFIG_CRASHLYTIX_APP_ID',
    defaultValue: 'Add Crashlytix App ID Here',
  );
  static const CONFIG_CRASHLYTIX_SERVER_ADDRESS = String.fromEnvironment(
    'CONFIG_CRASHLYTIX_SERVER_ADDRESS',
    defaultValue: 'http://87.107.165.4:8081/crashlytix/log',
  );
  static const APP_CONFIG_NAME = String.fromEnvironment(
    'APP_CONFIG_NAME',
    defaultValue: 'hemend',
  );
  static const APP_CONFIG_VERSION = String.fromEnvironment(
    'APP_CONFIG_VERSION',
    defaultValue: '0.1.2',
  );
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
      'HEMEND_CONFIG_IS_FORCED': HEMEND_CONFIG_IS_FORCED,
      'HEMEND_CONFIG_BUILD_MODE': HEMEND_CONFIG_BUILD_MODE,
      'HEMEND_CONFIG_RELEASE_MODE': HEMEND_CONFIG_RELEASE_MODE,
      'HEMEND_CONFIG_DEBUG_LEVEL': HEMEND_CONFIG_DEBUG_LEVEL,
      'HEMEND_CONFIG_BUILD_PLATFORM': HEMEND_CONFIG_BUILD_PLATFORM,
      'LAST_COMMIT_HASH': LAST_COMMIT_HASH,
      'LAST_COMMIT_AUTHOR_EMAIL': LAST_COMMIT_AUTHOR_EMAIL,
      'LAST_COMMIT_DATE_TIME': LAST_COMMIT_DATE_TIME,
      'ENV_CONFIG_API_VERSION': ENV_CONFIG_API_VERSION,
      'ENV_CONFIG_API_SUFFIX': ENV_CONFIG_API_SUFFIX,
      'ENV_CONFIG_RELEASE_TO': ENV_CONFIG_RELEASE_TO,
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
