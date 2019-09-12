import 'package:d_app/blocs/base_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';


class BlocProvider<B extends BaseBloc> extends Provider<B> {
  final Widget child;
  final B bloc;

  BlocProvider({
    Key key,
    this.child,
    @required this.bloc,
  })  : assert(bloc != null),
        super(
        key: key,
        builder: (_) => bloc,
        dispose: (_, b) => b.dispose,
        child: child,
      );
}