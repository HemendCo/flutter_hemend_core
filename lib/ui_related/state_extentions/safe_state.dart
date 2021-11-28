library hemend.ui.state_extentions;

import 'package:flutter/widgets.dart';

abstract class SafeState<T extends StatefulWidget> implements State<T> {
  @override
  void setState(VoidCallback fn) {
    if (mounted) setState(fn);
  }
}
