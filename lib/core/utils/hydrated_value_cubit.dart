import 'package:hydrated_bloc/hydrated_bloc.dart';

class HydratedValueCubit<T> extends HydratedCubit<T> {
  HydratedValueCubit(
    super.state, {
    required this.toJsonMapper,
    required this.fromJsonMapper,
  });
  final Map<String, dynamic>? Function(T state) toJsonMapper;
  final T? Function(Map<String, dynamic> json) fromJsonMapper;
  void setValue(T value) {
    emit(value);
  }

  T getValue() => state;

  @override
  T? fromJson(Map<String, dynamic> json) => fromJsonMapper(json);

  @override
  Map<String, dynamic>? toJson(T state) => toJsonMapper(state);
}

class HydratedValueCubitNullable<T> extends HydratedValueCubit<T?> {
  HydratedValueCubitNullable(
    super.state, {
    required super.toJsonMapper,
    required super.fromJsonMapper,
  });
}
