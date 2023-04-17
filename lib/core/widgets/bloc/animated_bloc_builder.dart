import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnimatedBlocBuilder<B extends StateStreamable<S>, S> extends BlocBuilder<B, S> {
  AnimatedBlocBuilder({
    super.key,
    required BlocWidgetBuilder<S> builder,
    super.bloc,
    super.buildWhen,
    required Duration duration,
    Duration? reverseDuration,
    Curve switchInCurve = Curves.linear,
    Curve switchOutCurve = Curves.linear,
    AnimatedSwitcherTransitionBuilder transitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    AnimatedSwitcherLayoutBuilder layoutBuilder = AnimatedSwitcher.defaultLayoutBuilder,
  }) : super(
          builder: (context, state) => AnimatedSwitcher(
            duration: duration,
            layoutBuilder: layoutBuilder,
            reverseDuration: reverseDuration,
            switchInCurve: switchInCurve,
            switchOutCurve: switchOutCurve,
            transitionBuilder: transitionBuilder,
            child: builder(context, state),
          ),
        );
}
