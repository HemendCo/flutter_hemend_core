// ignore_for_file: lines_longer_than_80_chars, constant_identifier_names, comment_references, avoid_equals_and_hash_code_on_mutable_classes

import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:string_scanner/string_scanner.dart';

extension PathTools on Path {
  void relativeHorizontalLineTo(double x) {
    relativeLineTo(x, 0);
  }

  void relativeVerticalLineTo(double y) {
    relativeLineTo(0, y);
  }

  void addFromSVGString(String value, [Offset offset = Offset.zero, Float64List? matrix4]) {
    addPath(SvgParser(value).parse(), offset, matrix4: matrix4);
  }
}

/// A Parser that converts a SVG path to a [Path] object.
/// Thanks to <a href="https://github.com/masterashu/svg_path_parser">masterashu</a>
class SvgParser {
  /// Creates a new [SvgParser] object.
  ///
  /// [source] should not be null.
  SvgParser(String source)
      : _scanner = Scanner(source),
        path = Path(),
        _initialPoint = Offset.zero,
        _currentPoint = Offset.zero,
        _lastCommandArgs = [];

  /// Last command Parsed
  late CommandToken _lastCommand;

  /// List of Arguments of Previous Command
  List<dynamic> _lastCommandArgs;

  /// The initial [Offset] where the [Path] object started from.
  Offset _initialPoint;

  /// The current [Offset] where the [Path] is currently at.
  Offset _currentPoint;

  /// The path object to be returned.
  Path path;

  /// The underlying [Scanner] which reads input source and emits [Token]s.
  final Scanner _scanner;

  /// Parses the SVG path.
  Path parse() {
    // Scan streamStart Token
    _parseStreamStart();

    while (_scanner.peek()!.type != TokenType.streamEnd) {
      _parseCommand();
    }

    _parseStreamEnd();

    return path;
  }

  /// Parses the stream start token.
  void _parseStreamStart() {
    _scanner.scan();
  }

  /// Parses the stream end token.
  void _parseStreamEnd() {
    _scanner.scan();
  }

  /// Parses a SVG path Command.
  void _parseCommand() {
    var token = _scanner.peek()!;
    // If extra arguments are encountered. Use the last command.
    if (token is! CommandToken) {
      // Subsequent pairs after first Move to are considered as implicit
      // Line to commands. https://www.w3.org/TR/SVG/paths.html#PathDataMovetoCommands
      if (_lastCommand.type == TokenType.moveTo) {
        token = CommandToken(TokenType.lineTo, _lastCommand.coordinateType);
      } else {
        token = _lastCommand;
      }
    } else {
      token = _scanner.scan()!;
    }

    switch (token.type) {
      case TokenType.moveTo:
        _parseMoveTo(token as CommandToken);
        return;
      case TokenType.closePath:
        _parseClosePath(token as CommandToken);
        return;
      case TokenType.lineTo:
        _parseLineTo(token as CommandToken);
        return;
      case TokenType.horizontalLineTo:
        _parseHorizontalLineTo(token as CommandToken);
        return;
      case TokenType.verticalLineTo:
        _parseVerticalLineTo(token as CommandToken);
        return;
      case TokenType.curveTo:
        _parseCurveTo(token as CommandToken);
        return;
      case TokenType.smoothCurveTo:
        _parseSmoothCurveTo(token as CommandToken);
        return;
      case TokenType.quadraticBezierCurveTo:
        _parseQuadraticBezierCurveTo(token as CommandToken);
        return;
      case TokenType.smoothQuadraticBezierCurveTo:
        _parseSmoothQuadraticBezierCurveTo(token as CommandToken);
        return;
      case TokenType.ellipticalArcTo:
        _parseEllipticalArcTo(token as CommandToken);
        return;
      default:
        return;
    }
  }

  /// Parses a [CommandToken] of type [TokenType.moveTo] and it's Argument [ValueToken]s.
  ///
  /// move-to-args: x, y            (absolute)
  /// move-to-args: dx, dy          (relative)
  void _parseMoveTo(CommandToken commandToken) {
    final x = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;
    final y = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;

    if (commandToken.coordinateType == CoordinateType.absolute) {
      path.moveTo(x, y);
      _currentPoint = Offset(x, y);
    } else {
      path.relativeMoveTo(x, y);
      _currentPoint = _currentPoint.translate(x, y);
    }
    // moveTo command reset the initial and current point
    _initialPoint = _currentPoint;

    _lastCommand = commandToken;
    _lastCommandArgs = [x, y];
  }

  /// Parses a [CommandToken] of type [TokenType.closePath].
  void _parseClosePath(CommandToken commandToken) {
    path.close();
    // closePath resets the current point to initial point.
    _currentPoint = _initialPoint;

    _lastCommand = commandToken;
    _lastCommandArgs.clear();
  }

  /// Parses a [CommandToken] of type [TokenType.lineTo] and it's Argument [ValueToken]s.
  ///
  /// line-to-args: x, y            (absolute)
  /// line-to-args: dx, dy          (relative)
  void _parseLineTo(CommandToken commandToken) {
    final x = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;
    final y = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;

    if (commandToken.coordinateType == CoordinateType.absolute) {
      path.lineTo(x, y);
      _currentPoint = Offset(x, y);
    } else {
      path.relativeLineTo(x, y);
      _currentPoint = _currentPoint.translate(x, y);
    }

    _lastCommand = commandToken;
    _lastCommandArgs = [x, y];
  }

  /// Parses a [CommandToken] of type [TokenType.horizontalLineTo] and it's Argument [ValueToken]s.
  ///
  /// horizontal-line-to-args: x     (absolute)
  /// horizontal-line-to-args: dx    (relative)
  void _parseHorizontalLineTo(CommandToken commandToken) {
    final h = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;

    final y = _currentPoint.dy;

    if (commandToken.coordinateType == CoordinateType.absolute) {
      path.lineTo(h, y);
      _currentPoint = Offset(h, y);
    } else {
      path.relativeLineTo(h, 0);
      _currentPoint = _currentPoint.translate(h, 0);
    }

    _lastCommand = commandToken;
    _lastCommandArgs = [h];
  }

  /// Parses a [CommandToken] of type [TokenType.verticalLineTo] and it's Argument [ValueToken]s.
  ///
  /// vertical-line-to-args: y        (absolute)
  /// vertical-line-to-args: dy       (relative)
  void _parseVerticalLineTo(CommandToken commandToken) {
    // final v = (_scanner.scan()! as ValueToken).value;
    final v = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;
    final x = _currentPoint.dx;

    if (commandToken.coordinateType == CoordinateType.absolute) {
      path.lineTo(x, v);
      _currentPoint = Offset(x, v);
    } else {
      path.relativeLineTo(0, v);
      _currentPoint = _currentPoint.translate(0, v);
    }

    _lastCommand = commandToken;
    _lastCommandArgs = [v];
  }

  /// Parses a [CommandToken] of type [TokenType.curveTo] and it's Argument [ValueToken]s.
  ///
  /// curve-to-args: x1,y1 x2,y2 x,y        (absolute)
  /// curve-to-args: dx1,dy1 dx2,dy2 dx,dy  (relative)
  void _parseCurveTo(CommandToken commandToken) {
    final x1 = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;
    final y1 = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;
    final x2 = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;
    final y2 = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;
    final x = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;
    final y = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;

    // final x1 = (_scanner.scan()! as ValueToken).value;
    // final y1 = (_scanner.scan()! as ValueToken).value;
    // final x2 = (_scanner.scan()! as ValueToken).value;
    // final y2 = (_scanner.scan()! as ValueToken).value;
    // final x = (_scanner.scan()! as ValueToken).value;
    // final y = (_scanner.scan()! as ValueToken).value;

    if (commandToken.coordinateType == CoordinateType.absolute) {
      path.cubicTo(x1, y1, x2, y2, x, y);
      _currentPoint = Offset(x, y);
    } else {
      path.relativeCubicTo(x1, y1, x2, y2, x, y);
      _currentPoint = _currentPoint.translate(x, y);
    }

    _lastCommand = commandToken;
    _lastCommandArgs = [x1, y1, x2, y2, x, y];
  }

  /// Parses a [CommandToken] of type [TokenType.smoothCurveTo] and it's Argument [ValueToken]s.
  ///
  /// smooth-curve-to-args: x1,y1 x,y        (absolute)
  /// smooth-curve-to-args: dx1,dy1 dx,dy    (relative)
  void _parseSmoothCurveTo(CommandToken commandToken) {
    final x2 = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;
    final y2 = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;
    final x = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;
    final y = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;
    // final x2 = (_scanner.scan()! as ValueToken).value;
    // final y2 = (_scanner.scan()! as ValueToken).value;
    // final x = (_scanner.scan()! as ValueToken).value;
    // final y = (_scanner.scan()! as ValueToken).value;
    // Calculate the first control point
    final cp = _calculateCubicControlPoint();

    if (commandToken.coordinateType == CoordinateType.absolute) {
      path.cubicTo(cp.dx, cp.dy, x2, y2, x, y);
      _currentPoint = Offset(x, y);
    } else {
      path.cubicTo(cp.dx - _currentPoint.dx, cp.dy - _currentPoint.dy, x2, y2, x, y);
      _currentPoint = _currentPoint.translate(x, y);
    }

    _lastCommand = commandToken;
    _lastCommandArgs = [x2, y2, x, y];
  }

  /// Parses a [CommandToken] of type [TokenType.quadraticBezierCurveTo] and it's Argument [ValueToken]s.
  /// Parses a [CommandToken] of type [TokenType.smoothCurveTo] and it's Argument [ValueToken]s.
  ///
  /// quadratic-curve-to-args: x1,y1 x,y        (absolute)
  /// quadratic-curve-to-args: dx1,dy1 dx,dy    (relative)
  void _parseQuadraticBezierCurveTo(CommandToken commandToken) {
    final x1 = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;
    final y1 = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;
    final x = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;
    final y = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;

    if (commandToken.coordinateType == CoordinateType.absolute) {
      path.quadraticBezierTo(x1, y1, x, y);
      _currentPoint = Offset(x, y);
    } else {
      path.relativeQuadraticBezierTo(x1, y1, x, y);
      _currentPoint = _currentPoint.translate(x, y);
    }

    _lastCommand = commandToken;
    _lastCommandArgs = [x1, y1, x, y];
  }

  /// Parses a [CommandToken] of type [TokenType.smoothQuadraticBezierCurveTo] and it's Argument [ValueToken]s.
  ///
  /// smooth-quadratic-curve-to-args: x,y         (absolute)
  /// smooth-quadratic-curve-to-args: dx,dy       (relative)
  void _parseSmoothQuadraticBezierCurveTo(CommandToken commandToken) {
    final x = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;
    final y = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;
    // Calculate the control point
    final cp = _calculateQuadraticControlPoint();

    if (commandToken.coordinateType == CoordinateType.absolute) {
      path.quadraticBezierTo(cp.dx, cp.dy, x, y);
      _currentPoint = Offset(x, y);
    } else {
      path.relativeQuadraticBezierTo(cp.dx - _currentPoint.dx, cp.dy - _currentPoint.dy, x, y);
      _currentPoint = _currentPoint.translate(x, y);
    }

    _lastCommand = commandToken;
    _lastCommandArgs = [cp.dx, cp.dy, x, y];
  }

  /// Parses a [CommandToken] of type [TokenType.ellipticalArcTo] and it's Argument [ValueToken]s.
  ///
  /// smooth-curve-to-args: rx ry x-axis-rotation large-arc-flag sweep-flag x y     (absolute)
  /// smooth-curve-to-args: rx ry x-axis-rotation large-arc-flag sweep-flag dx dy   (relative)
  void _parseEllipticalArcTo(CommandToken commandToken) {
    final rx = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;
    final ry = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;
    final theta = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;
    final fa = (_scanner.scan()! as ValueToken).value == 1;
    final fb = (_scanner.scan()! as ValueToken).value == 1;
    final x = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;
    final y = ((_scanner.scan()! as ValueToken).value ?? 0.0) as double;

    if (commandToken.coordinateType == CoordinateType.absolute) {
      path.arcToPoint(Offset(x, y), radius: Radius.elliptical(rx, ry), rotation: theta, largeArc: fa, clockwise: fb);
      _currentPoint = Offset(x, y);
    } else {
      path.relativeArcToPoint(
        Offset(x, y),
        radius: Radius.elliptical(rx, ry),
        rotation: theta,
        largeArc: fa,
        clockwise: fb,
      );
      _currentPoint = _currentPoint.translate(x, y);
    }

    _lastCommand = commandToken;
    _lastCommandArgs = [rx, ry, theta, fa, fb, x, y];
  }

  /// Predicts the Control Point [Offset] for a smooth cubic curve command.
  Offset _calculateCubicControlPoint() {
    if (_lastCommand.type == TokenType.curveTo) {
      if (_lastCommand.coordinateType == CoordinateType.absolute) {
        return _currentPoint + (_currentPoint - Offset(_lastCommandArgs[2], _lastCommandArgs[3]));
      } else {
        return _currentPoint - Offset(_lastCommandArgs[2], _lastCommandArgs[3]);
      }
    } else if (_lastCommand.type == TokenType.smoothCurveTo) {
      if (_lastCommand.coordinateType == CoordinateType.absolute) {
        return _currentPoint + (_currentPoint - Offset(_lastCommandArgs[0], _lastCommandArgs[1]));
      } else {
        return _currentPoint - Offset(_lastCommandArgs[0], _lastCommandArgs[1]);
      }
    } else {
      return _currentPoint;
    }
  }

  /// Predicts the Control Point [Offset] for a smooth quadratic bezier curve command.
  Offset _calculateQuadraticControlPoint() {
    if (_lastCommand.type == TokenType.quadraticBezierCurveTo) {
      if (_lastCommand.coordinateType == CoordinateType.absolute) {
        return _currentPoint + (_currentPoint - Offset(_lastCommandArgs[0], _lastCommandArgs[1]));
      } else {
        return _currentPoint - Offset(_lastCommandArgs[1], _lastCommandArgs[0]);
      }
    } else if (_lastCommand.type == TokenType.smoothQuadraticBezierCurveTo) {
      if (_lastCommand.coordinateType == CoordinateType.absolute) {
        return _currentPoint + (_currentPoint - Offset(_lastCommandArgs[0], _lastCommandArgs[1]));
      } else {
        return _currentPoint - Offset(_lastCommandArgs[0], _lastCommandArgs[1]);
      }
    } else {
      return _currentPoint;
    }
  }
}

/// A scanner that reads a string of Unicode characters and emits [Token]s.
///
/// This scanner is based on the guidelines provided by W3C on svg path,
/// available at https://www.w3.org/TR/SVG11/paths.html.
class Scanner {
  static const LETTER_A = 0x41;
  static const LETTER_a = 0x61;
  static const LETTER_C = 0x43;
  static const LETTER_c = 0x63;
  static const LETTER_E = 0x45;
  static const LETTER_e = 0x65;
  static const LETTER_h = 0x48;
  static const LETTER_H = 0x68;
  static const LETTER_L = 0x4c;
  static const LETTER_l = 0x6c;
  static const LETTER_M = 0x4d;
  static const LETTER_m = 0x6d;
  static const LETTER_Q = 0x51;
  static const LETTER_q = 0x71;
  static const LETTER_S = 0x53;
  static const LETTER_s = 0x73;
  static const LETTER_T = 0x54;
  static const LETTER_t = 0x74;
  static const LETTER_V = 0x56;
  static const LETTER_v = 0x76;
  static const LETTER_Z = 0x5a;
  static const LETTER_z = 0x7a;

  static const NUMBER_0 = 0x30;
  static const NUMBER_9 = 0x39;

  static const MINUS_SIGN = 0x2d;
  static const PLUS_SIGN = 0x2b;
  static const PERIOD = 0x2e;
  static const COMMA = 0x2c;
  static const SP = 0x20;

  /// The [RegExp] pattern to match a valid float value. Allowed float values include
  /// starting with decimal (.3) and exponent notation (1.3e+4).
  static final floatPattern = RegExp(r'[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?');

  /// The [RegExp] pattern to match a valid non-negative float value. Allowed float
  /// values include starting with decimal (.3) and exponent notation (1.3e+4).
  static final nonNegativeFloatPattern = RegExp(r'[+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?');

  /// The [RegExp] pattern to match a boolean flag (`1` or `0`).
  static final flagPattern = RegExp('(0|1)');

  /// Queue of tokens generated to be returned.
  final _tokens = Queue<Token>();

  /// The underlying StringScanner which scans the [source].
  final StringScanner _scanner;

  /// Is the stream end token is produced.
  bool _streamEndProduced = false;

  /// Is the stream start token is produced.
  bool _streamStartProduced = false;

  /// checks if the next character is a whitespace character.
  bool get _isWhitespace => _isWhitespaceAt(0);

  /// checks if the next character is a command character.
  bool get _isCommand => _isCommandAt(0);

  /// checks if the next character is a comma.
  bool get _isSeparator => _scanner.peekChar() == COMMA;

  /// checks if the end of string is reached.
  bool get isDone => _scanner.isDone;

  /// returns the [CoordinateType] based on the case of a character
  CoordinateType _coordinateType(char) {
    return _isLowerChar(char) ? CoordinateType.relative : CoordinateType.absolute;
  }

  bool _isWhitespaceAt(int offset) {
    final char = _scanner.peekChar(offset);
    return char == 0x20 || char == 0x9 || char == 0xd || char == 0xa;
  }

  bool _isCommandAt(int offset) {
    final char = _scanner.peekChar();
    return [
      LETTER_A,
      LETTER_a,
      LETTER_C,
      LETTER_c,
      LETTER_H,
      LETTER_h,
      LETTER_L,
      LETTER_l,
      LETTER_M,
      LETTER_m,
      LETTER_Q,
      LETTER_q,
      LETTER_S,
      LETTER_s,
      LETTER_T,
      LETTER_t,
      LETTER_V,
      LETTER_v,
      LETTER_Z,
      LETTER_z,
    ].contains(char);
  }

  bool _isLowerChar(int char) {
    return LETTER_a <= char && char <= LETTER_z;
  }

  /// Creates a [Scanner] that scans [source].
  ///
  /// [source] cannot be `null`.
  Scanner(String source) : _scanner = StringScanner(source);

  /// Consumes and returns the next token.
  Token? scan() {
    if (_streamEndProduced) return null;
    if (_tokens.isEmpty) _fetchNextToken();
    return _tokens.removeFirst();
  }

  /// Returns the next token without consuming it.
  Token? peek() {
    if (_streamEndProduced) return null;
    if (_tokens.isEmpty) _fetchNextToken();
    return _tokens.first;
  }

  /// Populates [_tokens] by fetching more tokens.
  void _fetchNextToken() {
    if (!_streamStartProduced) {
      _fetchStreamStart();
      return;
    }

    _scanToNextToken();

    if (_scanner.isDone) {
      _fetchStreamEnd();
      return;
    }

    if (_isCommand) {
      _fetchCommand();
      return;
    }

    _invalidCharacter(1);
  }

  /// Fetches a [CommandToken] and the required arguments' [ValueToken]s.
  void _fetchCommand() {
    final coordinateType = _coordinateType(_scanner.peekChar());
    final tokenType = _scanCommand();

    _tokens.add(CommandToken(tokenType, coordinateType));

    switch (tokenType) {
      case TokenType.ellipticalArcTo:
        _fetchArcCommandParams();
        return;
      case TokenType.curveTo:
        _fetchMultipleCoordinatePair(3);
        return;
      case TokenType.smoothCurveTo:
      case TokenType.quadraticBezierCurveTo:
        _fetchMultipleCoordinatePair(2);
        return;
      case TokenType.lineTo:
      case TokenType.moveTo:
      case TokenType.smoothQuadraticBezierCurveTo:
        _fetchCoordinatePair();
        return;
      case TokenType.horizontalLineTo:
      case TokenType.verticalLineTo:
        _fetchCoordinate();
        return;
      case TokenType.closePath:
        return;
      case TokenType.value:
        break;
      case TokenType.flag:
        break;
      case TokenType.streamStart:
        break;
      case TokenType.streamEnd:
        break;
    }
  }

  /// Consumes whitespaces and commas until the next token or
  /// the end of source is reached.
  void _scanToNextToken() {
    while (!isDone && (_isWhitespace || _isSeparator)) {
      _scanner.readChar();
    }
  }

  /// Consumes all the whitespace till a non-whitespace character occurs
  /// or till the end of the source.
  void _skipWhitespace() {
    while (!isDone && _isWhitespace) {
      _scanner.readChar();
    }
  }

  /// Fetches a stream start token.
  void _fetchStreamStart() {
    _tokens.add(const Token(TokenType.streamStart));
    _streamStartProduced = true;
  }

  /// Fetches a stream end token.
  void _fetchStreamEnd() {
    _tokens.add(const Token(TokenType.streamEnd));
    _streamEndProduced = true;
  }

  /// Fetches a comma but raises an error when a second comma is found.
  void _fetchSeparator() {
    _skipWhitespace();
    if (_scanner.scanChar(COMMA)) {
      _skipWhitespace();
      // Extra comma would raise an error.
      if (_scanner.peekChar() == COMMA) {
        _invalidCharacter(1);
      }
    }
    _skipWhitespace();
  }

  /// Fetch the next comma.
  void _fetchSingleSeparator() {
    _skipWhitespace();
    _scanner.scanChar(COMMA);
  }

  /// Fetch a float value.
  void _fetchFloatValue() => _tokens.add(ValueToken(TokenType.value, _scanFloatValue()));

  /// Fetch a non-negative float value.
  void _fetchNonNegativeFloatValue() {
    _tokens.add(ValueToken(TokenType.value, _scanNonNegativeFloatValue()));
  }

  /// Fetch a boolean (1 | 0) flag.
  void _fetchFlag() => _tokens.add(ValueToken(TokenType.flag, _scanFlag()));

  /// Fetch Parameters for ellipticalArcTo command.
  ///
  /// Production for ellipticalArcTo Arguments:
  ///   elliptical-arc-argument-sequence: elliptical-arc-argument+
  ///   elliptical-arc-argument:
  ///     nonnegative-number comma-wsp? nonnegative-number comma-wsp?
  ///       number comma-wsp flag comma-wsp? flag comma-wsp? coordinate-pair
  void _fetchArcCommandParams() {
    do {
      _skipWhitespace();
      _fetchNonNegativeFloatValue();
      _fetchSeparator();
      _fetchNonNegativeFloatValue();
      _fetchSeparator();
      _fetchFloatValue();
      _fetchSeparator();
      _fetchFlag();
      _fetchSeparator();
      _fetchFlag();
      _fetchSeparator();
      _fetchSingleCoordinatePair();
    } while (!isDone && !_isCommand);
  }

  /// Fetch coordinate Pairs for moveTo, LineTo, smoothQuadraticBezierCurveTo commands.
  ///
  /// Production for ellipticalArcTo Arguments:
  ///   lineno-argument-sequence:
  ///    coordinate-pair
  ///    | coordinate-pair comma-wsp? lineno-argument-sequence
  void _fetchCoordinatePair() {
    do {
      _skipWhitespace();
      _fetchSingleCoordinate();
      _fetchSeparator();
      _fetchSingleCoordinate();
      _fetchSingleSeparator();
    } while (!isDone && !_isCommand && !_isSeparator);
  }

  /// Fetch Single coordinates for horizontalMoveTo, verticalMoveTo commands.
  ///
  /// Production for ellipticalArcTo Arguments:
  ///   horizontal-lineno-argument-sequence:
  ///    coordinate
  ///    | coordinate comma-wsp? horizontal-lineno-argument-sequence
  void _fetchCoordinate() {
    do {
      _fetchSingleCoordinate();
      _fetchSingleSeparator();
    } while (!isDone && !_isCommand && !_isSeparator);
  }

  /// Fetch a single float value
  void _fetchSingleCoordinate() {
    _skipWhitespace();
    _fetchFloatValue();
    _skipWhitespace();
  }

  /// Fetch a single coordinate pair
  void _fetchSingleCoordinatePair() {
    _skipWhitespace();
    _fetchSingleCoordinate();
    _fetchSeparator();
    _fetchSingleCoordinate();
  }

  /// fetches Multiple coordinate Pairs.
  ///
  /// Used to fetch Arguments for curveTo, smoothCurveTo, quadraticBezierCurveTo commands.
  void _fetchMultipleCoordinatePair(int count) {
    do {
      for (var i = 1; i <= count; i++) {
        _skipWhitespace();
        _fetchSingleCoordinate();
        _fetchSeparator();
        _fetchSingleCoordinate();
        _fetchSingleSeparator();
      }
    } while (!isDone && !_isCommand && !_isSeparator);
  }

  /// scans the source and generates a [CommandToken].
  TokenType _scanCommand() {
    final char = _scanner.readChar();
    if (char == LETTER_A || char == LETTER_a) return TokenType.ellipticalArcTo;
    if (char == LETTER_C || char == LETTER_c) return TokenType.curveTo;
    if (char == LETTER_H || char == LETTER_h) return TokenType.horizontalLineTo;
    if (char == LETTER_L || char == LETTER_l) return TokenType.lineTo;
    if (char == LETTER_M || char == LETTER_m) return TokenType.moveTo;
    if (char == LETTER_Q || char == LETTER_q) {
      return TokenType.quadraticBezierCurveTo;
    }
    if (char == LETTER_S || char == LETTER_s) return TokenType.smoothCurveTo;
    if (char == LETTER_T || char == LETTER_t) {
      return TokenType.smoothQuadraticBezierCurveTo;
    }
    if (char == LETTER_V || char == LETTER_v) return TokenType.verticalLineTo;
    if (char == LETTER_Z || char == LETTER_z) return TokenType.closePath;
    return TokenType.closePath;
  }

  /// scans the source and generates a [ValueToken].
  double? _scanFloatValue() {
    if (_scanner.matches(floatPattern)) {
      _scanner.scan(floatPattern);
      return double.parse(_scanner.lastMatch!.group(0)!);
    } else {
      _expectedFloatValue();
    }
    return null;
  }

  /// scans the source and generates a [ValueToken].
  double? _scanNonNegativeFloatValue() {
    if (_scanner.matches(nonNegativeFloatPattern)) {
      _scanner.scan(nonNegativeFloatPattern);
      return double.parse(_scanner.lastMatch!.group(0)!);
    } else {
      _expectedNonNegativeFloatValue();
    }
    return null;
  }

  /// scans the source and generates a [ValueToken] having [TokenType.flag].
  int? _scanFlag() {
    if (_scanner.scan(flagPattern)) {
      return int.parse(_scanner.lastMatch!.group(0)!);
    } else {
      _expectedZeroOneValue();
    }
    return null;
  }

  /// Raise an error for a unexpected character.
  void _invalidCharacter([int length = 0]) {
    _scanner.error('Unexpected character.', length: length);
  }

  /// Raise an error when a float value is not found
  void _expectedFloatValue() {
    _scanner.error('Expected a float Value.');
  }

  /// Raise an error when a non-negative float value is not found
  void _expectedNonNegativeFloatValue() {
    _scanner.error('Expected a non-negative float Value.');
  }

  /// Raise an error when a boolean(1 | 0) is not found.
  void _expectedZeroOneValue() {
    _scanner.error('Expected a 0 or 1.');
  }
}

/// A token emitted by a [Scanner].
class Token {
  final TokenType type;

  const Token(this.type);

  @override
  String toString() {
    return 'Token $type';
  }

  @override
  bool operator ==(Object other) {
    return (other is Token) && type == other.type;
  }

  @override
  int get hashCode => type.hashCode;
}

/// A Token representing a command.
class CommandToken implements Token {
  @override
  final TokenType type;

  /// Type of coordinates to use for the command.
  final CoordinateType coordinateType;

  const CommandToken(this.type, [this.coordinateType = CoordinateType.absolute]);

  @override
  String toString() {
    return 'COMMAND $type ($coordinateType)';
  }

  @override
  bool operator ==(Object other) {
    if (other is CommandToken) {
      return type == other.type && coordinateType == other.coordinateType;
    }
    return false;
  }

  @override
  int get hashCode => type.hashCode * coordinateType.hashCode;
}

/// A token representing an argument value.
class ValueToken implements Token {
  @override
  final TokenType type;

  /// The value of the argument
  final Object? value;

  ValueToken(this.type, this.value);

  @override
  String toString() {
    return 'VALUE $type $value';
  }

  @override
  bool operator ==(Object other) {
    if (other is ValueToken) {
      return type == other.type && value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => type.hashCode * value.hashCode;
}

/// The types of [Token] objects.
enum TokenType {
  // Move To / Draw To Commands
  moveTo,
  closePath,
  lineTo,
  horizontalLineTo,
  verticalLineTo,
  curveTo,
  smoothCurveTo,
  quadraticBezierCurveTo,
  smoothQuadraticBezierCurveTo,
  ellipticalArcTo,

  // Command Parameters
  value,
  flag,

  // Stream Start/End
  streamStart,
  streamEnd
}

/// The types of coordinates to use for commands.
enum CoordinateType { absolute, relative }
