import 'package:flutter_bloc/flutter_bloc.dart';

class ValueCubit<T> extends Cubit<T> {
  ValueCubit(super.initialState);

  void setValue(T value) {
    emit(value);
  }

  T getValue() => state;
}

class ValueCubitNullable<T> extends ValueCubit<T?> {
  ValueCubitNullable([super.value]);
}
