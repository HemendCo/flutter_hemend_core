// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AutoRefreshWidget extends StatefulWidget {
  const AutoRefreshWidget({
    super.key,
    required this.builder,
    this.refreshDelay = const Duration(seconds: 1),
  });
  final Widget Function() builder;
  final Duration refreshDelay;

  @override
  _AutoRefreshWidgetState createState() => _AutoRefreshWidgetState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ObjectFlagProperty<Widget Function()>.has('builder', builder))
      ..add(DiagnosticsProperty<Duration>('refreshDelay', refreshDelay));
  }
}

class _AutoRefreshWidgetState extends State<AutoRefreshWidget> {
  late Timer timer;
  void refresh() {
    if (mounted) {
      setState(() {});
    }
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Timer>('timer', timer));
  }
}
