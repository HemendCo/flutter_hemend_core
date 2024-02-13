// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';

class MessageBoxSegment extends CustomPainter {
  MessageBoxSegment(
    this.radius,
    this.sharpPointSize, {
    this.sharpPointAtEnd = false,
    this.sharpPointOffset,
    this.sharpPointPath,
    this.painter,
  });
  final Radius radius;
  final Size sharpPointSize;
  final bool sharpPointAtEnd;
  final Offset? sharpPointOffset;
  final Path? sharpPointPath;
  final Paint? painter;
  @override
  void paint(Canvas canvas, Size size) {
    var canvasPainter = Paint();
    if (painter != null) {
      canvasPainter = painter!;
    } else {
      canvasPainter
        ..color = const Color(0xff447a9c)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1)
        ..style = PaintingStyle.stroke;
    }
    final path = MessageBoxSegment.messageBox(
      size.width,
      size.height,
      radius,
      sharpPointSize,
      sharpPointAtEnd,
      sharpPointOffset,
      sharpPointPath,
    );
    canvas.drawPath(path, canvasPainter);
  }

  static Path messageBox(
    double width,
    double height, [
    Radius borderRadius = Radius.zero,
    Size sharpPointSize = Size.zero,
    bool sharpPointAtEnd = false,
    Offset? sharpPointOffset,
    Path? sharpPointPath,
  ]) {
    ///Validating Size Values
    final boxWidth = width - sharpPointSize.width;
    final boxHeight = height - sharpPointSize.height;
    assert(boxWidth > 0, 'width must be greater than sharpPoint width');
    assert(boxHeight > 0, 'height must be greater than sharpPoint height');
    if (boxWidth < 0 || boxHeight < 0) {
      throw Exception(
        'with given base Size and sharp point Size its not possible to build path',
      );
    }

    ///Base Path Contains Box
    var path = Path();

    ///Will Contain SharpEdgePoint
    var sharpPoint = Path();

    ///Creating Base RoundRect
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(0, 0, boxWidth, boxHeight),
        borderRadius,
      ),
    );

    ///If there is no override for SharpEdge path will create one
    if (sharpPointPath != null) {
      sharpPoint = sharpPointPath;
    } else {
      sharpPoint
        ..moveTo(0, 0)
        ..lineTo(7, 2)
        ..lineTo(7, 7)
        ..lineTo(2, 7)
        ..lineTo(0, 0)
        ..close();
      sharpPoint = sharpPoint.shift(const Offset(-2, -2));
    }

    ///Set SharpEdge Size to given value
    final sharpPointPathSize = sharpPoint.getBounds().size;
    final scaleMatrix = Matrix4.identity()
      ..setEntry(0, 0, sharpPointSize.width / sharpPointPathSize.width)
      ..setEntry(1, 1, sharpPointSize.height / sharpPointPathSize.height);
    sharpPoint = sharpPoint.transform(scaleMatrix.storage);

    ///shift SharpEdge if there is offset override
    if (sharpPointOffset != null) {
      sharpPoint = sharpPoint.shift(sharpPointOffset);
    }

    ///Combine two path with [PathOperation.union]
    path = Path.combine(PathOperation.union, path, sharpPoint);

    ///revert whole shape vertically and horizontally to send sharp edge to bottomRight
    if (sharpPointAtEnd) {
      path = path.transform(Matrix4.diagonal3Values(-1, -1, 0).storage).shift(
            Offset(boxWidth, boxHeight),
          );
    }

    ///Validate final path size and offset to fit to size of view
    final finalPathBounds = path.getBounds();
    path = path.shift(Offset(-finalPathBounds.left, -finalPathBounds.top));
    final finalScaleMatrix = Matrix4.identity()
      ..setEntry(0, 0, width / finalPathBounds.size.width)
      ..setEntry(1, 1, height / finalPathBounds.size.height);
    // path = ;

    return path.transform(
      finalScaleMatrix.storage,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
