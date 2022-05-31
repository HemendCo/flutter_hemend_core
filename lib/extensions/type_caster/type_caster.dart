/// [TypeCaster] is used to cast values from [TBase] to [TDestination] and
/// wise versa
///
/// 1. It defines two functions, toBaseCaster and toDestinationCaster.
///
/// 2. The toBaseCaster function takes a TDestination and returns a TBase.
///
/// 3. The [toDestinationCaster] function takes a [TBase]
/// and returns a [TDestination].
///
/// 4. The constructor initializes the [TypeCaster] with the two functions.

class TypeCaster<TBase, TDestination> {
  final TBase Function(TDestination) toBaseCaster;
  final TDestination Function(TBase) toDestinationCaster;
  const TypeCaster({
    required this.toBaseCaster,
    required this.toDestinationCaster,
  });
}
