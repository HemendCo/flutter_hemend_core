import 'package:flutter/material.dart';

import '../state_extensions/overlay_mixin.dart';
import '../state_extensions/safe_state.dart';

class CustomSlider extends StatelessWidget {
  const CustomSlider({
    super.key,
    this.maximum = 1.0,
    this.minimum = 0.0,
    required this.initialValue,
    required this.onChanged,
    this.labelBuilder,
    this.labelMapper,
    required this.leftSideDecoration,
    required this.rightSideDecoration,
    required this.valueIndicatorBuilder,
    this.animationDuration = const Duration(milliseconds: 150),
  });
  final double maximum;
  final double minimum;
  final double initialValue;
  final void Function(double) onChanged;
  final Widget Function(String)? labelBuilder;
  final String Function(double)? labelMapper;
  final BoxDecoration Function(bool, double) leftSideDecoration;
  final BoxDecoration Function(bool, double) rightSideDecoration;
  final Duration animationDuration;
  final Widget Function(
    bool,
    double,
  ) valueIndicatorBuilder;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewSize = constraints.biggest;
        return _CustomSliderView(
          key: key != null ? ValueKey(key!.hashCode) : null,
          viewSize: viewSize,
          maximum: maximum,
          minimum: minimum,
          initialValue: initialValue,
          onChanged: onChanged,
          animationDuration: animationDuration,
          labelBuilder: labelBuilder,
          labelMapper: labelMapper,
          leftSideDecoration: leftSideDecoration,
          rightSideDecoration: rightSideDecoration,
          valueIndicatorBuilder: valueIndicatorBuilder,
        );
      },
    );
  }
}

class _CustomSliderView extends StatefulWidget {
  const _CustomSliderView({
    super.key,
    required this.viewSize,
    required this.maximum,
    required this.minimum,
    required this.initialValue,
    required this.onChanged,
    this.labelBuilder,
    this.labelMapper,
    required this.leftSideDecoration,
    required this.rightSideDecoration,
    required this.valueIndicatorBuilder,
    required this.animationDuration,
  });
  final Duration animationDuration;
  final Size viewSize;
  final double maximum;
  final double minimum;
  final double initialValue;
  final void Function(double) onChanged;
  final Widget Function(String)? labelBuilder;
  final String Function(double)? labelMapper;
  final BoxDecoration Function(bool, double) leftSideDecoration;
  final BoxDecoration Function(bool, double) rightSideDecoration;
  final Widget Function(
    bool,
    double,
  ) valueIndicatorBuilder;

  @override
  State<_CustomSliderView> createState() => _CustomSliderViewState();
}

// ignore: lines_longer_than_80_chars
class _CustomSliderViewState extends SafeState<_CustomSliderView> with OverlayerViewMixin {
  late double _value = widget.initialValue;
  double get value => _value;
  set value(double input) {
    if (input != value) {
      setState(() {
        _value = input;
      });
      widget.onChanged(_value);
    }
  }

  double get valuePercent => changeValueScope(
        baseValue: value,
        baseMin: widget.minimum,
        baseMax: widget.maximum,
      );
  set valuePercent(double input) => value = changeValueScope(
        baseValue: input,
        baseMax: 1,
        dstMax: widget.maximum,
        dstMin: widget.minimum,
      );
  double get selectorOffset => changeValueScope(
        baseValue: value,
        baseMin: widget.minimum,
        baseMax: widget.maximum,
        dstMax: widget.viewSize.width,
      );
  set selectorOffset(double input) {
    value = changeValueScope(
      baseValue: toValidPosition(input),
      baseMax: widget.viewSize.width,
      dstMax: widget.maximum,
      dstMin: widget.minimum,
    );
  }

  double toValidPosition(double pos) {
    if (pos < 0) {
      return 0;
    }
    if (pos > widget.viewSize.width) {
      return widget.viewSize.width;
    }
    return pos;
  }

  double get rightSideSize => widget.viewSize.width - selectorOffset;
  double changeValueScope({
    num baseMin = 0,
    required num baseValue,
    num baseMax = double.infinity,
    num dstMin = 0,
    num dstMax = 1,
  }) {
    final cnvMax = baseMax - baseMin;
    final cnvValue = baseValue - baseMin;
    final cnvDstMax = dstMax - dstMin;
    final result = cnvValue * cnvDstMax / cnvMax + dstMin;
    return result;
  }

  bool _isDown = false;
  bool get isDown => _isDown;
  set isDown(bool isDown) {
    if (_isDown == false && isDown == true) {
      insertOverlays();
    } else if (isDown == false) {
      refreshOverlays();
      removeOverlays();
    } else {
      refreshOverlays();
    }
    if (_isDown != isDown) {
      setState(() {
        _isDown = isDown;
      });
    }
  }

  void pointerEventHandler(PointerEvent event) {
    selectorOffset = event.localPosition.dx;
    isDown = event.down;
  }

  final LayerLink layerLink = LayerLink();
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: pointerEventHandler,
      onPointerUp: pointerEventHandler,
      onPointerMove: pointerEventHandler,
      child: Row(
        children: [
          ///left wing view
          SizedBox(
            width: selectorOffset,
            child: AnimatedContainer(
              duration: widget.animationDuration,
              decoration: widget.leftSideDecoration(_isDown, valuePercent),
            ),
          ),

          ///center point
          CompositedTransformTarget(link: layerLink),

          ///right wing view
          SizedBox(
            width: rightSideSize,
            child: AnimatedContainer(
              duration: widget.animationDuration,
              decoration: widget.rightSideDecoration(_isDown, valuePercent),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLabel() {
    final label = (widget.labelMapper ?? (d) => d.toStringAsFixed(1))(_value);
    if (widget.labelBuilder != null) {
      return widget.labelBuilder!(label);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 51, 42, 42),
        borderRadius: BorderRadius.all(
          Radius.circular(
            15,
          ),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Map<OverlayEntryKey, OverlayEntry> get overlayEntries => _overlays;
  late final Map<OverlayEntryKey, OverlayEntry> _overlays = {
    const OverlayEntryKey(
      'Main indicator',
      [
        OverlayMode.cannotBeRemoved,
        OverlayMode.addAtStart,
      ],
    ): OverlayEntry(
      builder: (context) {
        final size = widget.viewSize.height;
        return Positioned(
          top: 0,
          left: 0,
          child: SizedBox(
            height: size,
            width: size,
            child: CompositedTransformFollower(
              offset: Offset(-(size - size / 2), -(size - size / 2)),
              link: layerLink,
              child: widget.valueIndicatorBuilder(
                _isDown,
                valuePercent,
              ),
            ),
          ),
        );
      },
    ),
    const OverlayEntryKey(
      'Label Indicator',
    ): OverlayEntry(
      builder: (context) {
        final size = widget.viewSize.height * 1.5;
        return Positioned(
          top: 0,
          left: 0,
          child: SizedBox(
            height: size,
            width: size,
            child: CompositedTransformFollower(
              targetAnchor: Alignment.topCenter,
              offset: Offset(
                -(size - size / 2),
                -(size * 1.3),
              ),
              link: layerLink,
              child: Material(
                color: Colors.transparent,
                child: FittedBox(child: buildLabel()),
              ),
            ),
          ),
        );
      },
    ),
  };
}
