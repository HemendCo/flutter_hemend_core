import 'package:flutter/material.dart';

class RoundEdge extends ShapeBorder {
  const RoundEdge({
    this.curveBaseDistanceWidth = 1,
    double? curveBaseDistanceHeight,
    this.curveWeight = 5,
    this.offset = Offset.zero,
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
  final Offset offset;
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final offsetWidth = rect.width * curveBaseDistanceWidth * 0.5;
    final offsetHeight = rect.height * curveBaseDistanceHeight * 0.5;
    final path = Path()
      ..moveTo(-offsetWidth, 0)
      ..conicTo(0, 0, 0, offsetHeight, curveWeight)
      ..lineTo(0, rect.height - offsetHeight)
      ..conicTo(0, rect.height, offsetWidth, rect.height, curveWeight)
      ..lineTo(rect.width - offsetWidth, rect.height)
      ..conicTo(
        rect.width,
        rect.height,
        rect.width,
        rect.height - offsetHeight,
        curveWeight,
      )
      ..lineTo(rect.width, offsetHeight)
      ..conicTo(
        rect.width,
        0,
        rect.width + offsetWidth,
        0,
        curveWeight,
      )
      ..lineTo(-offsetWidth, 0)
      ..close();
    return path.shift(
      rect.topLeft.translate(
        offset.dx,
        offset.dy,
      ),
    );
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
    return RoundEdge(
      curveBaseDistanceWidth: curveBaseDistanceWidth * t,
      curveBaseDistanceHeight: curveBaseDistanceHeight * t,
      curveWeight: curveWeight * t,
      offset: offset.scale(t, t),
    );
  }
}

class RoundEdgeBorder extends RoundEdge implements OutlinedBorder {
  const RoundEdgeBorder({
    super.curveBaseDistanceWidth,
    super.curveBaseDistanceHeight,
    super.curveWeight,
    super.painter,
    super.offset,
    this.side = BorderSide.none,
  });

  @override
  OutlinedBorder copyWith({BorderSide? side}) {
    return RoundEdgeBorder(
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

class RoundEdgeDecoration extends ShapeDecoration {
  RoundEdgeDecoration({
    double curveBaseDistanceWidth = 0.9,
    double? curveBaseDistanceHeight,
    double curveWeight = 5,
    super.color,
    super.image,
    super.gradient,
    super.shadows,
    Offset offset = Offset.zero,
  }) : super(
          shape: RoundEdge(
            curveBaseDistanceWidth: curveBaseDistanceWidth,
            curveBaseDistanceHeight: curveBaseDistanceHeight,
            curveWeight: curveWeight,
            offset: offset,
          ),
        );
}
