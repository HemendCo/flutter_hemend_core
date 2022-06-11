import 'package:hemend/debug/error_handler.dart';
import 'package:rive/rive.dart' show Artboard, SMIInput, StateMachine, StateMachineController;
import 'package:rive/src/rive_core/state_machine_controller.dart' show OnStateChange;

class RiveSimpleToggleController extends StateMachineController {
  // final StateMachineController _stateMachineController;

  bool _isToggled = true;

  RiveSimpleToggleController(
    super.stateMachine, {
    super.onStateChange,
  });
  factory RiveSimpleToggleController.fromArtboard(
    Artboard artboard,
    String stateMachineName, {
    OnStateChange? onStateChange,
  }) {
    for (final animation in artboard.animations) {
      if (animation is StateMachine && animation.name == stateMachineName) {
        return RiveSimpleToggleController(animation, onStateChange: onStateChange);
      }
    }
    throw const ErrorHandler('error creating controller for artboard');
  }
  // RiveSimpleToggleController({
  //   required StateMachineController stateMachineController,
  //   bool isToggled = false,
  //   bool isUnderPressure = false,
  // })  : _isToggled = isToggled,
  //       _isUnderPressure = isUnderPressure,
  //       _stateMachineController = stateMachineController;

  bool get isToggled => _isToggled;

  set isToggled(bool isToggled) {
    _toggleInput.value = isToggled;
    _isToggled = isToggled;
  }

  bool _isUnderPressure = false;

  bool get isUnderPressure => _isUnderPressure;

  set isUnderPressure(bool underLongPressure) {
    _longPressInput.value = underLongPressure;
    _isUnderPressure = underLongPressure;
  }

  void toggle() {
    isToggled = !isToggled;
  }

  SMIInput<bool>? _toggleInputPointer;
  SMIInput<bool>? _longPressInputPointer;
  SMIInput<bool> get _toggleInput {
    if (_toggleInputPointer != null) {
      return _toggleInputPointer!;
    }
    _toggleInputPointer = findSMI('active_state');
    if (_toggleInputPointer == null) {
      throw const ErrorHandler(
        'Could not find active_state input',
        {
          ErrorType.notFound,
        },
      );
    }
    return _toggleInputPointer!;
  }

  SMIInput<bool> get _longPressInput {
    if (_longPressInputPointer != null) {
      return _longPressInputPointer!;
    }
    _longPressInputPointer = findSMI('long_press_state');
    if (_longPressInputPointer == null) {
      throw const ErrorHandler(
        'Could not find long_press_state input',
        {
          ErrorType.notFound,
        },
      );
    }
    return _longPressInputPointer!;
  }
}
