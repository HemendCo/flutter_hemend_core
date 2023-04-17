import 'package:flutter/material.dart';

class SafeExpanded extends StatelessWidget {
  const SafeExpanded({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return SizedBox.fromSize(
      size: mediaQuery.size,
      child: Padding(
        padding: mediaQuery.padding,
        child: child,
      ),
    );
  }
}
