import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum DebugSegments {
  slider,
  textInput,
}

class DebugViewBuilder extends StatefulWidget {
  const DebugViewBuilder({
    super.key,
    required this.segments,
    required this.builder,
    required this.height,
    required this.segmentsListHeight,
    required this.width,
    this.segmentListColor = const Color(0x00000000),
    this.eachSegmentColor = const Color(0x00000000),
  });
  final double height;
  final double segmentsListHeight;
  final double width;
  final Color segmentListColor;
  final Color eachSegmentColor;
  final List<DebugSegments> segments;
  final Widget Function(
    BuildContext context,
    List<dynamic> segmentsResults,
  ) builder;
  @override
  // ignore: library_private_types_in_public_api
  _DebugViewBuilderState createState() => _DebugViewBuilderState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('height', height))
      ..add(DoubleProperty('segmentsListHeight', segmentsListHeight))
      ..add(DoubleProperty('width', width))
      ..add(ColorProperty('segmentListColor', segmentListColor))
      ..add(ColorProperty('eachSegmentColor', eachSegmentColor))
      ..add(IterableProperty<DebugSegments>('segments', segments))
      ..add(
        ObjectFlagProperty<
            Widget Function(
              BuildContext context,
              List<Object> segmentsResults,
            )>.has('builder', builder),
      );
  }
}

class _DebugViewBuilderState extends State<DebugViewBuilder> {
  List<dynamic> segmentValues = [];
  @override
  void initState() {
    for (final segment in widget.segments) {
      switch (segment) {
        case DebugSegments.slider:
          segmentValues.add(0.0);
        case DebugSegments.textInput:
          segmentValues.add('');
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final output = widget.builder(context, segmentValues);
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        children: [
          output,
          Container(
            color: widget.segmentListColor,
            height: widget.segmentsListHeight,
            child: ListView.separated(
              separatorBuilder: (context, index) => Container(
                height: 5,
                color: Colors.black45,
              ),
              itemBuilder: (_, index) {
                switch (widget.segments[index]) {
                  case DebugSegments.slider:
                    return DecoratedBox(
                      decoration: BoxDecoration(color: widget.eachSegmentColor),
                      child: Slider(
                        value: segmentValues[index] as double,
                        onChanged: (value) => setState(() {
                          segmentValues[index] = value;
                        }),
                      ),
                    );
                  case DebugSegments.textInput:
                    return SizedBox(
                      width: widget.width,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.eachSegmentColor,
                        ),
                        child: TextField(
                          onChanged: (value) => setState(() {
                            segmentValues[index] = value;
                          }),
                        ),
                      ),
                    );
                }
              },
              itemCount: widget.segments.length,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<dynamic>('segmentValues', segmentValues));
  }
}
