import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocProviderProxyBuilder<T extends StateStreamableSource<Object?>> //
    extends BlocProvider<T> {
  BlocProviderProxyBuilder({
    super.key,
    required super.create,
    super.lazy = true,
    required WidgetBuilder builder,
  }) : super(
          child: Builder(builder: builder),
        );
}
