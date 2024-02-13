import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

extension StringTools on String {
  String withComma({
    String comma = ',',
    String sign = '',
  }) {
    final stripped = replaceAll(comma, '').replaceAll(RegExp(r'[^\d]'), '');
    final reversed = stripped.codeUnits.reversed;
    final output = StringBuffer(sign);
    var counter = 0;
    for (final i in reversed) {
      if (counter % 3 == 0 && counter != 0) {
        output.write(comma);
      }
      counter++;
      output.writeCharCode(i);
    }
    return String.fromCharCodes(
      output.toString().codeUnits.reversed,
    );
  }

  Iterable<TextSpan> asClickableTextSpans(
    BuildContext context, {
    String? text,
    required FutureOr<void> Function(Uri uri) onClick,
  }) sync* {
    text ??= this;
    final uriMatch = urlMatcher.firstMatch(text);
    if (uriMatch != null) {
      yield TextSpan(
        text: text.substring(0, uriMatch.start),
      );
      final uri = Uri.parse(text.substring(uriMatch.start, uriMatch.end));
      yield TextSpan(
        text: uri.toString(),
        locale: const Locale('en', 'US'),
        recognizer: TapGestureRecognizer()..onTap = () {},
        style: const TextStyle(
          color: Colors.blueAccent,
          decorationStyle: TextDecorationStyle.dotted,
          decorationThickness: 2,
          decoration: TextDecoration.underline,
        ),
      );
      yield* asClickableTextSpans(
        context,
        text: text.substring(uriMatch.end, text.length),
        onClick: onClick,
      );
    } else {
      final phoneMatch = phoneMatcher.firstMatch(text);
      if (phoneMatch != null) {
        yield TextSpan(
          text: text.substring(0, phoneMatch.start),
        );
        final phone = text.substring(phoneMatch.start, phoneMatch.end);
        yield TextSpan(
          text: phone,
          locale: const Locale('en', 'US'),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              await onClick(
                Uri.parse('tel:$phone'),
              );
            },
          style: const TextStyle(
            color: Colors.blueAccent,
            decorationStyle: TextDecorationStyle.dotted,
            decorationThickness: 2,
            decoration: TextDecoration.underline,
          ),
        );
        yield* asClickableTextSpans(
          context,
          text: text.substring(phoneMatch.end, text.length),
          onClick: onClick,
        );
      } else {
        yield TextSpan(text: text);
      }
    }
  }

  static final urlMatcher = RegExp(
    r'(?<schema>[^\s:\/]+):(\/){2}(?<host_ame>[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6})\b\/?([-a-zA-Z0-9()@:%_\+.~#?&=]*)(\/(([-a-zA-Z0-9_])+))*(\?(?<query_params>&?(?<key>[-a-zA-Z0-9_]+)=(?<value>[-a-zA-Z0-9_]+))*)?',
  );
  static final phoneMatcher = RegExp(
    r'\+98[0-9]{10}',
  );
}
