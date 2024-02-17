import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hemend_logger/hemend_logger.dart';
part 'l10n_error.dart';

mixin L10nStringMixin {
  Map<Locale, String> get translation;
  Locale get fallbackLocale;
  Logger get logger => Logger('L10nStringMixin');
  String call(BuildContext context) => toStringOf(context);
  String of(BuildContext context) => toStringOf(context);
  String toStringOf(BuildContext context) {
    final l = logger.getChild('toStringOf');
    final locale = Localizations.maybeLocaleOf(context);
    if (locale == null) {
      l.severe(
        () => '''Current context does not carry any locale information, using fallbackLocale($fallbackLocale)''',
      );
    } else {
      l.fine(() => 'Found App locale($locale)');
    }
    return ofLocale(
      locale ?? fallbackLocale,
    );
  }

  String ofLocale(Locale locale) {
    assert(
      () {
        if (!translation.keys.contains(locale)) {
          logger.getChild('ofLocale').shout(
                () => '''Translation map does not contain any result for locale($locale)''',
              );
        }
        return true;
      }(),
      '',
    );
    assert(
      translation.containsKey(fallbackLocale),
      'Translation map must contain fallbackLocale($fallbackLocale) key',
    );
    final resolved = translation[locale] ?? translation[fallbackLocale];
    if (resolved == null) {
      _notFound(locale);
    }
    return resolved;
  }
}

final class L10nString extends Equatable with L10nStringMixin {
  L10nString({
    Locale? fallbackLocale,
    required Map<Locale, String> translation,
  })  : assert(
          translation.isNotEmpty,
          'Translation Map cannot be empty',
        ),
        translation = Map.unmodifiable(translation),
        fallbackLocale = fallbackLocale ?? translation.keys.first;

  @override
  final Locale fallbackLocale;

  @override
  final Map<Locale, String> translation;

  @override
  List<Object?> get props => [
        fallbackLocale,
        ...translation.entries,
      ];
}
