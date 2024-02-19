import '../../contracts/typedefs/typedefs.dart';
import 'option.dart';

extension CheckAllOptionsExt on Iterable<Option<Object?>> {
  /// returns true if all of the items inside iterable are [Some]
  bool areSome() => map(
        (element) => element.isSome,
      )
          .where(
            (element) => !element,
          )
          .isEmpty;

  /// returns true if all of the items inside iterable are [None]
  bool areNone() => map(
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

extension ExportFromVisitorExt<T, R extends T> on //
    void Function(Adapter<T, bool>) {
  /// Iterates through visitor and returns visited node of type [R]
  /// that passed the [test] with true result returns [Some], otherwise
  /// continues iteration and if no result where found returns [None]
  Option<R> export(Adapter<T, bool> test) {
    Option<R> result = None<R>();
    this(
      (item) {
        if (item is R && test(item)) {
          result = Some(item);
          return false;
        }
        return true;
      },
    );
    return result;
  }
}
