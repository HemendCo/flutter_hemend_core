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
          throw Exception('S is not implemented yet');
          break;
        case 's':
          //TESTING
          throw Exception('s is not implemented yet');
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
          throw Exception('T is not implemented yet');
          break;
        case 'A':
          throw Exception('Arc is not implemented yet');
          break;
        case 't':
          throw Exception('t implemented yet');
          break;
        case 'a':
          throw Exception('relative Arc is implemented yet');
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
