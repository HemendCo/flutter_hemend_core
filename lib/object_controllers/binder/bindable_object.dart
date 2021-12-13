import 'package:flutter/material.dart';
import 'package:hemend/ui_related/state_extensions/safe_state.dart';

abstract class SingleBindableObject implements BaseBindableObject {
  BindableState? _bondedState;
  @override
  bool get isBonded => _bondedState != null;
  @override
  void bind(BindableState state) {
    assert(!isBonded,
        'Assertion Failed this bindable object is singleBounded and cant have 2 state at same time use MultipleBindableObject instead if needed');
    if (isBonded) return;
    _bondedState = state;
    onBind();
  }

  @override
  void onBind([BindableState? state]) {
    if (!isBonded) return;
    _bondedState!.update(this);
  }

  @override
  void unBind(BindableState state) {
    _bondedState = null;
  }

  @override
  void update() {
    if (_bondedState == null) return;
    _bondedState!.update(this);
  }
}

abstract class MultipleBindableObject implements BaseBindableObject {
  final List<BindableState> _bondedStates = [];
  @override
  bool get isBonded => _bondedStates.isNotEmpty;

  @override
  void bind(BindableState state) {
    _bondedStates.add(state);
    onBind(state);
  }

  @override
  void onBind([BindableState? state]) {
    if (state != null) {
      state.update(this);
    } else {
      update();
    }
  }

  @override
  void unBind(BindableState state) {
    _bondedStates.remove(state);
  }

  @override
  void update() {
    for (final state in _bondedStates) {
      state.update(this);
    }
  }
}

abstract class BaseBindableObject {
  BaseBindableObject._();
  bool get isBonded;
  void bind(BindableState state);
  void onBind([BindableState? state]);
  void unBind(BindableState state);
  void update();
}

abstract class BindableState<T extends StatefulWidget,
        B extends BaseBindableObject> extends SafeState<T>
    implements _ObjectCarrier<B> {
  bool get isBonded => bondedObject != null;
  void update(B object) => setState(() {});

  @override
  void initState() {
    super.initState();
    if (isBonded) {
      bondedObject!.bind(this);
    }
  }

  @override
  void dispose() {
    if (isBonded) {
      bondedObject!.unBind(this);
    }

    super.dispose();
  }
}

abstract class _ObjectCarrier<T> {
  T? get bondedObject => null;
}
