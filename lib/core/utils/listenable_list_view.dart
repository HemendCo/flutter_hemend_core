import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotifiedListView extends StatelessWidget {
  const NotifiedListView({
    super.key,
    required this.builder,
    this.padding = EdgeInsets.zero,
    required this.onLastItemBuilt,
    required this.count,
    this.physics = const BouncingScrollPhysics(),
  });
  final NullableIndexedWidgetBuilder builder;
  final int count;
  final EdgeInsets padding;
  final void Function() onLastItemBuilt;
  final ScrollPhysics physics;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: count,
      padding: padding,
      physics: physics,
      itemBuilder: (context, index) {
        if (index == count - 1) {
          onLastItemBuilt();
        }
        return builder(context, index);
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        ObjectFlagProperty<NullableIndexedWidgetBuilder>.has(
          'builder',
          builder,
        ),
      )
      ..add(IntProperty('count', count))
      ..add(DiagnosticsProperty<EdgeInsets>('padding', padding))
      ..add(
        ObjectFlagProperty<void Function()>.has(
          'onLastItemBuilt',
          onLastItemBuilt,
        ),
      )
      ..add(DiagnosticsProperty<ScrollPhysics>('physics', physics));
  }
}
