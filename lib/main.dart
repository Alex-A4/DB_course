import 'package:db_course_mobile/src/app.dart';
import 'package:flutter/material.dart';

void main() => runApp(AppBase(key: Key('AppBase')));

/// Входная точка в приложение, которая задаёт основные экраны
class AppBase extends StatelessWidget {
  AppBase({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (_) => App(),
      },
      initialRoute: '/',
    );
  }
}
