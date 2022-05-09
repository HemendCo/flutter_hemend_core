import 'package:flutter/material.dart';
import '../../extensions/size_extensions.dart';
import '../state_extensions/safe_state.dart';

class BuildInFuture<T> extends StatefulWidget {
  ///async object that your widget needs its value
  final Future<T?> itemFromFuture;

  ///build your widget with data grabbed from async item
  final Widget Function(
    BuildContext,
    T? data,
    void Function(Future<T?>) rebuildPulse,
  ) childInFuture;

  ///place holder of final widget until data receive
  final Widget? placeHolder;

  const BuildInFuture({
    Key? key,
    required this.itemFromFuture,
    required this.childInFuture,
    this.placeHolder,
  }) : super(key: key);

  @override
  _BuildInFutureState createState() => _BuildInFutureState<T>();
}

class _BuildInFutureState<T> extends SafeState<BuildInFuture<T>> {
  bool inited = false;
  T? data;
  late Widget child;
  void rebuildWithValueOf(Future<T?> preLoad) async {
    data = await preLoad;
    setState(() {
      child = widget.childInFuture(context, data, rebuildWithValueOf);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!inited) {
      if (widget.placeHolder == null) {
        child = Center(
          child: Container(
            height: 5.percentOfHeight(context),
            width: 5.percentOfHeight(context),
            child: const CircularProgressIndicator(),
            padding: EdgeInsets.all(5.percentOfWidth(context)),
          ),
        );
      } else {
        child = widget.placeHolder!;
      }

      inited = true;
      widget.itemFromFuture.then(
        (v) => setState(() {
          data = v;
          child = widget.childInFuture(context, data, rebuildWithValueOf);
        }),
      );
    }
    return Container(
      child: child,
    );
  }
}
