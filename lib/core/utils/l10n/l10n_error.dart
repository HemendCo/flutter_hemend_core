part of 'l10n_string.dart';

sealed class L10nException implements Exception {}

final class L10nNotFoundError implements L10nException {
  L10nNotFoundError({
    required this.message,
    required this.locale,
    required this.fallbackLocale,
    required this.translationMap,
  });

  final String message;
  final Locale locale;
  final Locale fallbackLocale;
  final Map<Locale, String> translationMap;

  @override
  String toString() {
    return '''

** $message **

RequestedLocale: $locale
FallbackLocale: $fallbackLocale

translationMap: ${translationMap.entries.map((e) => '`${e.key}``: `${e.value}``}').join('|')}
''';
  }
}

extension L10nExceptionHelper on L10nStringMixin {
  Never _notFound(
    Locale locale,
  ) {
    throw L10nNotFoundError(
      message: 'Cannot find given locale and fallback local in translation',
      locale: locale,
      fallbackLocale: fallbackLocale,
      translationMap: translation,
    );
  }
}
