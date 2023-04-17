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
      itemBuilder: (BuildContext context, int index) {
        if (index == count - 1) {
          onLastItemBuilt();
        }
        return builder(context, index);
      },
    );
  }
}
