import 'package:db_course_mobile/src/bloc/navigation_bloc/navigation.dart';
import 'package:db_course_mobile/src/models/user.dart';
import 'package:flutter/material.dart';

class UserWidget extends StatelessWidget {
  final User user;
  final NavigationBloc bloc;

  UserWidget({Key key, @required this.user, @required this.bloc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userName = '${user.name.substring(0, 1).toUpperCase()}'
        '${user.lastName.substring(0, 1).toUpperCase()}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: InkWell(
        onTap: () => bloc.dispatch(LogInRemembered(user)),
        child: Card(
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CircleAvatar(
              child: Text(userName, style: TextStyle(color: Colors.white)),
              radius: 20,
              backgroundColor: user.isAdmin
                  ? Colors.red[400]
                  : user.isMaster
                      ? Colors.green[600]
                      : Colors.indigo[400],
            ),
          ),
        ),
      ),
    );
  }
}
