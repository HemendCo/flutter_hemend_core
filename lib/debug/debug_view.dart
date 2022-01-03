import 'package:flutter/material.dart';

enum DebugSegments {
  slider,
  textInput,
}

class DebugViewBuilder extends StatefulWidget {
  const DebugViewBuilder({
    Key? key,
    required this.segments,
    required this.builder,
    required this.height,
    required this.segmentsListHeight,
    required this.width,
    this.segmentListColor = const Color(0x00000000),
    this.eachSegmentColor = const Color(0x00000000),
  }) : super(key: key);
  final double height;
  final double segmentsListHeight;
  final double width;
  final Color segmentListColor;
  final Color eachSegmentColor;
  final List<DebugSegments> segments;
  final Widget Function(BuildContext context, List<dynamic> segmentsResults)
      builder;
  @override
  _DebugViewBuilderState createState() => _DebugViewBuilderState();
}

class _DebugViewBuilderState extends State<DebugViewBuilder> {
  List<dynamic> segmentValues = [];
  @override
  void initState() {
    for (final segment in widget.segments) {
      switch (segment) {
        case DebugSegments.slider:
          segmentValues.add(0.0);
          break;
        case DebugSegments.textInput:
          segmentValues.add('');
          break;
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
              separatorBuilder: (context, index) =>
                  Container(height: 5, color: Colors.black45),
              itemBuilder: (_, index) {
                switch (widget.segments[index]) {
                  case DebugSegments.slider:
                    return DecoratedBox(
                      decoration: BoxDecoration(color: widget.eachSegmentColor),
                      child: Slider(
                          value: segmentValues[index],
                          onChanged: (value) => setState(() {
                                segmentValues[index] = value;
                              })),
                    );
                  case DebugSegments.textInput:
                    return SizedBox(
                      width: widget.width,
                      child: DecoratedBox(
                        decoration:
                            BoxDecoration(color: widget.eachSegmentColor),
                        child: TextField(
                            onChanged: (value) => setState(() {
                                  segmentValues[index] = value;
                                })),
                      ),
                    );
                }
              },
              itemCount: widget.segments.length,
            ),
          )
        ],
      ),
    );
  }
}
