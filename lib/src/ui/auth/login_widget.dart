import 'package:flutter/material.dart';

class LogInWidget extends StatefulWidget {
  LogInWidget({Key key}) : super(key: key);

  @override
  _LogInWidgetState createState() => _LogInWidgetState();
}

class _LogInWidgetState extends State<LogInWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: double.infinity),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('Авторизация'),
          Text('Логин'),
          Text('Пароль'),
        ],
      ),
    );
  }
}
