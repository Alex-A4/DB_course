import 'package:db_course_mobile/src/bloc/navigation_bloc/navigation.dart';
import 'package:db_course_mobile/src/ui/auth/login_widget.dart';
import 'package:db_course_mobile/src/ui/auth/user_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  final String error;

  AuthScreen({Key key, this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NavigationBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Вход')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Запомненные пользователи',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: bloc.users.length,
                itemBuilder: (_, index) =>
                    UserWidget(user: bloc.users[index], bloc: bloc),
              ),
            ),
            Divider(thickness: 2),
            LogInWidget(),
          ],
        ),
      ),
    );
  }
}
