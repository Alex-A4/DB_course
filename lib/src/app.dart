import 'package:flutter/material.dart';

class App extends StatelessWidget {
  App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Приложение')),
      body: Center(child: Text('Старт')),
    );
  }
}
