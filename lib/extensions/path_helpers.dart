import 'package:flutter/rendering.dart';

import 'package:hemend/extensions/string_helpers.dart';

extension PathTools on Path {
  void relativeHorizontalLineTo(double x) {
    relativeLineTo(x, 0);
  }

  void relativeVerticalLineTo(double y) {
    relativeLineTo(0, y);
  }

  void addFromSvgString(String value) {
    //M 0 0 L 2 0 V 2 H 3 C 3 3 3 4 2 4 S 0.817 3.156 0 3 Q -2 3 -2 1 T -3.99 0.991 A 1 1 0 1 0 -4.419 -0.786 Z
    final data = _parseSvgPathToList(value);
    Offset baseOffset = Offset.zero;
    for (final segment in data) {
      final splitSegment = segment.split(' ');

      String token = splitSegment[0];
      switch (token) {
        case 'M':
          baseOffset =
              Offset(splitSegment[1].toDouble(), splitSegment[2].toDouble());
          moveTo(splitSegment[1].toDouble(), splitSegment[2].toDouble());
          break;
        case 'm':
          baseOffset = Offset(baseOffset.dx + splitSegment[1].toDouble(),
              baseOffset.dy + splitSegment[2].toDouble());
          relativeMoveTo(
              splitSegment[1].toDouble(), splitSegment[2].toDouble());
          break;
        case 'L':
          lineTo(splitSegment[1].toDouble(), splitSegment[2].toDouble());
          break;
        case 'l':
          relativeLineTo(
              splitSegment[1].toDouble(), splitSegment[2].toDouble());
          break;
        case 'V':
          relativeVerticalLineTo(splitSegment[1].toDouble() - baseOffset.dy);
          break;
        case 'v':
          relativeVerticalLineTo(splitSegment[1].toDouble());
          break;
        case 'H':
          relativeHorizontalLineTo(splitSegment[1].toDouble() - baseOffset.dx);
          break;
        case 'h':
          relativeHorizontalLineTo(splitSegment[1].toDouble());
          break;
        case 'C':
          cubicTo(
              splitSegment[1].toDouble(),
              splitSegment[2].toDouble(),
              splitSegment[3].toDouble(),
              splitSegment[4].toDouble(),
              splitSegment[5].toDouble(),
              splitSegment[6].toDouble());
          break;
        case 'c':
          relativeCubicTo(
              splitSegment[1].toDouble(),
              splitSegment[2].toDouble(),
              splitSegment[3].toDouble(),
              splitSegment[4].toDouble(),
              splitSegment[5].toDouble(),
              splitSegment[6].toDouble());
          break;
        case 'S':
          //TESTING
          throw Exception('not implemented yet');
          break;
        case 's':
          //TESTING
          throw Exception('not implemented yet');
          break;
        case 'Q':
          quadraticBezierTo(
              splitSegment[1].toDouble(),
              splitSegment[2].toDouble(),
              splitSegment[3].toDouble(),
              splitSegment[4].toDouble());
          break;
        case 'q':
          relativeQuadraticBezierTo(
              splitSegment[1].toDouble(),
              splitSegment[2].toDouble(),
              splitSegment[3].toDouble(),
              splitSegment[4].toDouble());
          break;
        case 'T':
          throw Exception('not implemented yet');
          break;
        case 'A':
          throw Exception('not implemented yet');
          break;
        case 't':
          throw Exception('not implemented yet');
          break;
        case 'a':
          throw Exception('not implemented yet');
          break;
        default:
          close();
      }
    }
  }

  static List<String> _parseSvgPathToList(String path, [List<String>? items]) {
    items = items ?? [];
    if (path.isEmpty) {
      return items;
    } else {
      final detectedPart = _getFirstPathPart(path);
      final passingPath = path.replaceFirst(detectedPart, '');
      items.add(detectedPart);
      return _parseSvgPathToList(passingPath, items);
    }
  }

  static String _getFirstPathPart(String path) {
    StringBuffer buffer = StringBuffer();
    int index = 0;
    bool foundToken = false;
    while (index < path.length) {
      final c = path[index];
      if (c.isChar() && foundToken) {
        break;
      }
      buffer.write(c);
      index++;
      if (c.isChar()) {
        foundToken = true;
      }
    }
    return buffer.toString();
  }
}
