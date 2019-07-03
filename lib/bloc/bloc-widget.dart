import 'package:flutter/material.dart';

import 'bloc-base.dart';

class BlocWidget<T extends BlocBase> extends StatefulWidget {
  final Widget child;
  final T bloc;

  BlocWidget({Key key, @required this.bloc, @required this.child})
      : super(key: key);

  static T of<T extends BlocBase>(BuildContext context) {
    Type type = _typeOf<BlocWidget<T>>();
    BlocWidget<T> blocWidget = context.ancestorWidgetOfExactType(type);
    return blocWidget.bloc;
  }

  static Type _typeOf<T>() => T;

  @override
  State<StatefulWidget> createState() {
    return _BlocState();
  }
}

class _BlocState<T> extends State<BlocWidget<BlocBase>> {
  @override
  Widget build(BuildContext context) {
    widget.bloc.init();
    return widget.child;
  }

  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }
}
