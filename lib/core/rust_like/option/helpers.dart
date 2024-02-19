import 'option.dart';

extension CheckAllOptionsExt on Iterable<Option<Object?>> {
  /// returns true if all of the items inside iterable are [Some]
  bool allSome() => map(
        (element) => element.isSome,
      )
          .where(
            (element) => !element,
          )
          .isEmpty;

  /// returns true if all of the items inside iterable are [None]
  bool allNone() => map(
        (element) => element.isNone,
      )
          .where(
            (element) => !element,
          )
          .isEmpty;
}

extension SomeExporterOptionsExt<T> on Iterable<Option<T>> {
  /// returns all [Some] values inside the iterable
  Iterable<T> exportSome() => whereType<Some<T>>().map(
        (e) => e.value,
      );
}

extension WrapInOption<T> on T? {
  Option<T> get opt => Option.wrap(this);
}

extension WrapInOptionS<T> on Iterable<T?> {
  Iterable<Option<T>> get opts => map(Option.wrap);
}
