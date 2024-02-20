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
  Option<R> intoSafe<R>() {
    if (this is R) {
      return Some(this as R);
    }
    return None<R>();
  }
}

extension WrapInOptionS<T> on Iterable<T?> {
  Iterable<Option<T>> get opts => map(Option.wrap);
}

extension ExportFromVisitorExt<T> on void Function(Adapter<T, bool>) {
  /// Exports elements from a visitor based on a selector function.
  /// The selector function maps an element of type T to an Option<R> object.
  /// The function will iterate through the collection and update the result
  /// with the value from the selector.
  ///
  /// If the selector returns a Some<R> object, the function will return false
  /// to stop the iteration.
  ///
  /// Otherwise, the function will continue iterating.
  /// The method returns the Some<R> if fount any otherwise returns None<R>.
  Option<R> export<R>(Adapter<T, Option<R>> selector) {
    Option<R> result = None<R>();
    this(
      (item) {
        final selected = selector(item);
        switch (selected) {
          case Some<R>():
            result = selected;
            return false;
          default:
            return true;
        }
      },
    );
    return result;
  }

  /// Exports all elements from a collection that are of type R.
  /// The function will iterate through the collection and add elements that are
  /// of type R to the result list.
  List<R> exportAll<R>() {
    final result = List<R>.empty(growable: true);
    this(
      (p0) {
        if (p0 is R) {
          result.add(p0);
        }
        return true;
      },
    );
    return result;
  }

  /// Exports elements from a collection based on a selector function and a
  /// predicate function.
  ///
  /// The predicate function takes an element of type R and returns a boolean
  /// value.
  ///
  /// The function will iterate through the collection and add elements that
  /// satisfy the predicate function to the result list.
  List<R> exportWhere<R extends T>(Adapter<R, bool> test) {
    final result = List<R>.empty(growable: true);
    this(
      (p0) {
        if (p0 is R && test(p0)) {
          result.add(p0);
        }
        return true;
      },
    );
    return result;
  }
}
