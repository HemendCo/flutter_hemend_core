import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HiddenWrapperController<T extends Widget> extends Cubit<bool> {
  HiddenWrapperController() : super(true);
  void show() => emit(true);
  void hide() => emit(false);
  void toggle() => state ? hide() : show();
}
