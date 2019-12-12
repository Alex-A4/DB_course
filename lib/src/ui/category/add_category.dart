import 'package:db_course_mobile/src/bloc/navigation_bloc/navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddCategoryScreen extends StatelessWidget {
  final _key = GlobalKey<FormState>();
  final controller = TextEditingController();
  final Function onSuccess;

  AddCategoryScreen({Key key, this.onSuccess}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NavigationBloc>(context);
    final user = bloc.user;

    return Form(
      key: _key,
      child: ListTile(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextFormField(
          controller: controller,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: 'Название категории',
            contentPadding:
            EdgeInsets.symmetric(horizontal: 20),
          ),
          validator: (v) {
            if (v.isEmpty) return 'Название не пустое';
            return null;
          },
        ),
        trailing: IconButton(
          icon: Icon(Icons.check, color: Colors.green[300]),
          onPressed: () {
            if (_key.currentState.validate()) {
              bloc.database.addCategory(user.token, controller.text);
              onSuccess();
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }
}
