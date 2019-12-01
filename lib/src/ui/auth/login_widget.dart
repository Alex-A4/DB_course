import 'package:db_course_mobile/src/bloc/navigation_bloc/navigation.dart';
import 'package:db_course_mobile/src/database/tables/user_table.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWidget extends StatefulWidget {
  final String error;

  AuthWidget({Key key, this.error}) : super(key: key);

  @override
  _AuthWidgetState createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  bool signUp = false;

  @override
  Widget build(BuildContext context) {
    return signUp
        ? SignUpWidget(
            key: Key('SignUpWidget'),
            onTap: () => setState(() => signUp = false),
            error: widget.error,
          )
        : LogInWidget(
            key: Key('LogInWidget'),
            onTap: () => setState(() => signUp = true),
            error: widget.error,
          );
  }
}

class SignUpWidget extends StatefulWidget {
  final Function onTap;
  final String error;

  SignUpWidget({Key key, @required this.onTap, this.error}) : super(key: key);

  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final GlobalKey<FormState> _key = GlobalKey();

  Roles role = Roles.Master;

  double priceCoef = 1.0;

  final loginController = TextEditingController();

  final passwordController = TextEditingController();

  final nameController = TextEditingController();

  final lastNameController = TextEditingController();

  final cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NavigationBloc>(context);

    return Container(
      constraints: BoxConstraints(minWidth: double.infinity),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Form(
          key: _key,
          child: Column(
            children: <Widget>[
              Text('Регистрация', style: headerStyle),
              SizedBox(height: 20),

              /// Роль
              Text('Роль'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Radio(
                    groupValue: role.index,
                    onChanged: (index) => setState(() => role = Roles.Master),
                    value: 0,
                  ),
                  Text('Мастер'),
                  SizedBox(width: 20),
                  Radio(
                    groupValue: role.index,
                    value: 1,
                    onChanged: (index) => setState(() => role = Roles.Client),
                  ),
                  Text('Клиент'),
                ],
              ),

              /// Имя
              SizedBox(height: 10),
              Text('Имя'),
              Card(
                elevation: 5,
                child: TextFormField(
                  controller: nameController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Имя',
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    border: UnderlineInputBorder(borderSide: BorderSide.none),
                  ),
                  validator: (value) {
                    if (value.isEmpty) return 'Имя не должно быть пустым';
                    return null;
                  },
                ),
              ),

              /// Фамилия
              SizedBox(height: 10),
              Text('Фамилия'),
              Card(
                elevation: 5,
                child: TextFormField(
                  controller: lastNameController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Фамилия',
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    border: UnderlineInputBorder(borderSide: BorderSide.none),
                  ),
                  validator: (value) {
                    if (value.isEmpty) return 'Фамилия не должна быть пустой';
                    return null;
                  },
                ),
              ),

              /// Телефон
              SizedBox(height: 10),
              Text('Номер телефона'),
              Card(
                elevation: 5,
                child: TextFormField(
                  controller: loginController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Телефон',
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    border: UnderlineInputBorder(borderSide: BorderSide.none),
                  ),
                  validator: (value) {
                    if (value.isEmpty)
                      return 'Номер телефона не должен быть пустым';
                    return null;
                  },
                ),
              ),

              /// Пароль
              SizedBox(height: 10),
              Text('Пароль'),
              Card(
                elevation: 5,
                child: TextFormField(
                  controller: passwordController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    border: UnderlineInputBorder(borderSide: BorderSide.none),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty) return 'Пароль не должен быть пустым';
                    return null;
                  },
                ),
              ),

              ///Город
              if (role == Roles.Master)
                SizedBox(height: 10),
              if (role == Roles.Master)
                Text('Город'),
              if (role == Roles.Master)
                Card(
                  elevation: 5,
                  child: TextFormField(
                    controller: cityController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'Город',
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      border: UnderlineInputBorder(borderSide: BorderSide.none),
                    ),
                    validator: (value) {
                      if (value.isEmpty) return 'Город не должен быть пустым';
                      return null;
                    },
                  ),
                ),

              /// Цена
              if (role == Roles.Master)
                SizedBox(height: 10),
              if (role == Roles.Master)
                Text('Коэффициент цены'),
              if (role == Roles.Master)
                Slider(
                  value: priceCoef,
                  onChanged: (value) => setState(() => priceCoef = value),
                  min: 0.5,
                  max: 1.8,
                  divisions: 13,
                  label: priceCoef.toStringAsFixed(1),
                ),

              SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: 'Есть аккаунт?',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = widget.onTap,
                ),
              ),
              SizedBox(height: 20),
              if (widget.error != null)
                Text(
                  widget.error,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[400], fontSize: 20),
                ),
              if (widget.error != null)
                SizedBox(height: 20),

              FlatButton(
                padding: EdgeInsets.symmetric(horizontal: 20),
                textColor: Colors.white,
                color: Colors.blue,
                child: Text('Создать аккаунт'),
                onPressed: () {
                  if (_key.currentState.validate()) {
                    bloc.dispatch(SignUpUser(
                      role,
                      loginController.text,
                      nameController.text,
                      lastNameController.text,
                      role == Roles.Master ? cityController.text : null,
                      role == Roles.Master ? priceCoef : null,
                      passwordController.text,
                    ));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LogInWidget extends StatelessWidget {
  final Function onTap;
  final String error;
  final GlobalKey<FormState> _key = GlobalKey();
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  LogInWidget({Key key, @required this.onTap, this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NavigationBloc>(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      constraints: BoxConstraints(minWidth: double.infinity),
      child: Form(
        key: _key,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (error != null)
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[400], fontSize: 20),
              ),
            if (error != null) SizedBox(height: 20),
            Text('Авторизация', style: headerStyle),
            SizedBox(height: 10),
            Text('Номер телефона'),
            Card(
              elevation: 5,
              child: TextFormField(
                controller: loginController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Телефон',
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  border: UnderlineInputBorder(borderSide: BorderSide.none),
                ),
                validator: (value) {
                  if (value.isEmpty)
                    return 'Номер телефона не должен быть пустым';
                  return null;
                },
              ),
            ),
            SizedBox(height: 10),
            Text('Пароль'),
            Card(
              elevation: 5,
              child: TextFormField(
                controller: passwordController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  border: UnderlineInputBorder(borderSide: BorderSide.none),
                ),
                obscureText: true,
                validator: (value) {
                  if (value.isEmpty) return 'Пароль не должен быть пустым';
                  return null;
                },
              ),
            ),
            RichText(
              text: TextSpan(
                text: 'Нет аккаунта?',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()..onTap = onTap,
              ),
            ),
            SizedBox(height: 20),
            FlatButton(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              textColor: Colors.white,
              color: Colors.blue,
              child: Text('Войти'),
              onPressed: () {
                if (_key.currentState.validate()) {
                  bloc.dispatch(
                    LogInUser(loginController.text, passwordController.text),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

final headerStyle = TextStyle(
    fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic);
