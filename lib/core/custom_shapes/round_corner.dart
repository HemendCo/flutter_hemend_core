import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RoundRect extends ShapeBorder {
  const RoundRect({
    this.curveBaseDistanceWidth = 1,
    double? curveBaseDistanceHeight,
    this.curveWeight = 5,
    this.painter,
  })  : curveBaseDistanceHeight = curveBaseDistanceHeight ?? //
            curveBaseDistanceWidth,
        assert(
          curveBaseDistanceWidth >= 0 && curveBaseDistanceWidth <= 1,
          'Value of CurveBaseDistanceWidth must be positive and lower than `1`',
        ),
        assert(
          curveBaseDistanceHeight == null || //
              curveBaseDistanceHeight >= 0 && curveBaseDistanceHeight <= 1,
          '''Value of CurveBaseDistanceHeight must be positive and lower than `1`''',
        ),
        assert(
          curveWeight >= 0,
          // ignore: lines_longer_than_80_chars
          'Value of curveWeight must be positive',
        );

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;
  final double curveBaseDistanceWidth;
  final double curveBaseDistanceHeight;
  final double curveWeight;
  final Paint? painter;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final offsetWidth = rect.width * curveBaseDistanceWidth * 0.5;
    final offsetHeight = rect.height * curveBaseDistanceHeight * 0.5;
    final path = Path()
      ..moveTo(0, offsetHeight)
      ..conicTo(0, 0, offsetWidth, 0, curveWeight)
      ..lineTo(rect.width - offsetWidth, 0)
      ..conicTo(rect.width, 0, rect.width, offsetHeight, curveWeight)
      ..lineTo(rect.width, rect.height - offsetHeight)
      ..conicTo(
        rect.width,
        rect.height,
        rect.width - offsetWidth,
        rect.height,
        curveWeight,
      )
      ..lineTo(offsetWidth, rect.height)
      ..conicTo(
        0,
        rect.height,
        0,
        rect.height - offsetHeight,
        curveWeight,
      )
      ..lineTo(0, offsetHeight)
      ..close();
    return path.shift(rect.topLeft);
  }

  @override
  Path getOuterPath(
    Rect rect, {
    TextDirection? textDirection,
  }) =>
      getInnerPath(
        rect,
        textDirection: textDirection,
      );

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (painter != null) {
      canvas.drawPath(
        getInnerPath(
          rect,
          textDirection: textDirection,
        ),
        painter!,
      );
    }
  }

  @override
  ShapeBorder scale(double t) {
    return RoundRect(
      curveBaseDistanceWidth: curveBaseDistanceWidth * t,
      curveBaseDistanceHeight: curveBaseDistanceHeight * t,
      curveWeight: curveWeight * t,
    );
  }
}

class RoundRectBorder extends RoundRect implements OutlinedBorder {
  const RoundRectBorder({
    super.curveBaseDistanceWidth,
    super.curveBaseDistanceHeight,
    super.curveWeight,
    super.painter,
    this.side = BorderSide.none,
  });

  @override
  OutlinedBorder copyWith({BorderSide? side}) {
    return RoundRectBorder(
      side: side ?? this.side,
      curveBaseDistanceWidth: curveBaseDistanceWidth,
      curveBaseDistanceHeight: curveBaseDistanceHeight,
      curveWeight: curveWeight,
      painter: painter,
    );
  }

  @override
  final BorderSide side;
}

class RoundRectDecoration extends ShapeDecoration {
  RoundRectDecoration({
    this.curveBaseDistanceWidth = 1,
    this.curveBaseDistanceHeight,
    this.curveWeight = 5,
    super.color,
    super.image,
    super.gradient,
    super.shadows,
  }) : super(
          shape: RoundRect(
            curveBaseDistanceWidth: curveBaseDistanceWidth,
            curveBaseDistanceHeight: curveBaseDistanceHeight,
            curveWeight: curveWeight,
          ),
        );
  final double curveBaseDistanceWidth;
  final double? curveBaseDistanceHeight;
  final double curveWeight;
  RoundRectDecoration copyWith({
    double? curveBaseDistanceWidth,
    double? curveBaseDistanceHeight,
    double? curveWeight,
    Color? color,
    DecorationImage? image,
    Gradient? gradient,
    List<BoxShadow>? shadows,
  }) =>
      RoundRectDecoration(
        curveBaseDistanceWidth: curveBaseDistanceWidth ?? //
            this.curveBaseDistanceWidth,
        curveBaseDistanceHeight: curveBaseDistanceHeight ?? //
            this.curveBaseDistanceHeight,
        curveWeight: curveWeight ?? this.curveWeight,
        color: color ?? this.color,
        image: image ?? this.image,
        gradient: gradient ?? this.gradient,
        shadows: shadows ?? this.shadows,
      );
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('curveBaseDistanceWidth', curveBaseDistanceWidth))
      ..add(DoubleProperty('curveBaseDistanceHeight', curveBaseDistanceHeight))
      ..add(DoubleProperty('curveWeight', curveWeight));
  }
}
