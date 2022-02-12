import 'dart:async';

import 'package:flutter/material.dart';

class AutoRefreshWidget extends StatefulWidget {
  final Widget Function() builder;
  final Duration refreshDelay;
  const AutoRefreshWidget(
      {Key? key,
      required this.builder,
      this.refreshDelay = const Duration(seconds: 1)})
      : super(key: key);

  @override
  _AutoRefreshWidgetState createState() => _AutoRefreshWidgetState();
}

class _AutoRefreshWidgetState extends State<AutoRefreshWidget> {
  late Timer timer;
  void refresh() {
    if (mounted) setState(() {});
    timer = Timer(const Duration(milliseconds: 20), refresh);
  }

  @override
  void initState() {
    super.initState();
    timer = Timer(const Duration(milliseconds: 20), refresh);
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder();
  }
}
