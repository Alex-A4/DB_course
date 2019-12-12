import 'package:db_course_mobile/src/bloc/navigation_bloc/navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddSubcategoryScreen extends StatelessWidget {
  final _key = GlobalKey<FormState>();
  final String categoryName;
  final int categoryId;
  final nameController = TextEditingController();
  final priceController = TextEditingController(text: '100');
  final timeController = TextEditingController(text: '30');

  AddSubcategoryScreen(
      {Key key, @required this.categoryId, @required this.categoryName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NavigationBloc>(context);
    final user = bloc.user;

    return Scaffold(
      appBar: AppBar(title: Text('Добавить подкатегорию')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Form(
          key: _key,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Добавление в $categoryName'),
                  SizedBox(height: 20),
                  Material(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                    color: Colors.white,
                    child: TextFormField(
                      controller: nameController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Название подкатегории',
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      ),
                      maxLength: 15,
                      validator: (v) {
                        if (v.isEmpty) return 'Название не пустое';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Material(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                    color: Colors.white,
                    child: TextFormField(
                      controller: priceController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Цена',
                        contentPadding: EdgeInsets.symmetric(horizontal: 50),
                        suffix: Text('руб'),
                      ),
                      maxLength: 4,
                      validator: (v) {
                        if (v.isEmpty) return 'Цена не пустая';
                        if (double.tryParse(v) == null)
                          return 'Должно быть число';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Material(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                    color: Colors.white,
                    child: TextFormField(
                      controller: timeController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Время выполнения',
                        contentPadding: EdgeInsets.symmetric(horizontal: 50),
                        suffix: Text('мин'),
                      ),
                      maxLength: 3,
                      validator: (v) {
                        if (v.isEmpty) return 'Время не пустое';
                        if (int.tryParse(v) == null) return 'Должно быть целое';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  FlatButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: Text('Добавить подкатегорию'),
                    onPressed: () {
                      if (_key.currentState.validate()) {
                        bloc.database.addSubcategory(
                          user.token,
                          nameController.text,
                          categoryId,
                          double.parse(priceController.text),
                          int.parse(timeController.text),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
