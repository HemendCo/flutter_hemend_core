import 'package:flutter/material.dart';
import 'package:hemend/ui_related/state_extensions/safe_state.dart';

class CountDownTimer {
  String get hours => alterIntToStr(_duration.inHours % 24, ssz);
  String get minutes => alterIntToStr(_duration.inMinutes % 60, ssz);
  String get seconds => alterIntToStr(_duration.inSeconds % 60, true);
  bool get isNegetive => _duration.isNegative;
  final bool ssz;
  Duration _duration;
  final bool Function(Duration)? timerCondition;
  Duration get asDuration => _duration;
  final void Function()? onTick;
  Future<void> startTimer() async {
    while (!_duration.isNegative) {
      _duration = Duration(seconds: (_duration.inSeconds - 1));
      (onTick ?? () {})();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  CountDownTimer(Duration duration,
      {this.onTick, this.ssz = true, this.timerCondition})
      : _duration = duration;

  String alterIntToStr(int v, bool ssz) {
    assert(() {
      return v < 100;
    }());
    String result = v.toString();
    if (v < 10) {
      result = '0$result';
    }
    if (!ssz && result == '00') {
      result = '';
    }
    return result;
  }

  @override
  String toString() {
    String result = '';
    if (hours.isNotEmpty) {
      result += '$hours:';
    }
    if (minutes.isNotEmpty) {
      result += '$minutes:';
    }

    result += seconds;

    return (isNegetive ? '-' : '') + result;
  }
}

class TimerViewMaster extends StatefulWidget {
  TimerViewMaster(
      {Key? key,
      DateTime? finalDate,
      Duration? duration,
      this.showZeroValues = true,
      required this.builder})
      : super(key: key) {
    final fromDate = finalDate != null;
    final fromDuration = duration != null;

    assert(() {
      return fromDate != fromDuration;
    }());
    if (fromDate) {
      endTime = finalDate;
    } else {
      endTime = DateTime.now().add(duration!);
    }
  }
  final bool showZeroValues;
  final Widget Function(BuildContext, CountDownTimer) builder;
  late final DateTime endTime;
  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends SafeState<TimerViewMaster> {
  late final time =
      CountDownTimer((widget.endTime).difference(DateTime.now()), onTick: () {
    setState(() {});
  })
        ..startTimer();

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, time);
  }
}
