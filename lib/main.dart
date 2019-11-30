import 'package:db_course_mobile/src/app.dart';
import 'package:db_course_mobile/src/bloc/navigation_bloc/navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  final bloc = NavigationBloc();
  bloc.dispatch(InitEvent());

  runApp(AppBase(bloc: bloc));
}

/// Входная точка в приложение, которая задаёт основные экраны
/// и провайдер блока
class AppBase extends StatelessWidget {
  final NavigationBloc bloc;

  AppBase({Key key, this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<NavigationBloc>(
      builder: (_) => bloc,
      dispose: (_, b) => b.dispose(),
      child: MaterialApp(
        routes: {
          '/': (_) => App(key: Key('App')),
        },
        initialRoute: '/',
      ),
    );
  }
}
