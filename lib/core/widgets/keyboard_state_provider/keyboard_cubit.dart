part of 'keyboard_state_provider.dart';

class KeyboardCubit extends Cubit<KeyboardState> {
  KeyboardCubit._() : super(KeyboardState.initial);
  int firstCounter = 0;
  void _updateKeyboardState(bool state) {
    final newState = state ? KeyboardState.open : KeyboardState.close;
    emit(newState);
  }

  void killFocus() => FocusManager.instance.rootScope.unfocus();
}
