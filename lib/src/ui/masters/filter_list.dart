import 'package:db_course_mobile/src/bloc/navigation_bloc/navigation.dart';
import 'package:db_course_mobile/src/models/subcategory.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Экран фильтров мастера.
/// Фильтрация по:
/// 1) Компетенции мастера
/// 2) Городу проживания мастера
/// 3) Категории мастера
class FilterScreen extends StatelessWidget {
  final cityController = TextEditingController();
  final _key = GlobalKey<FormState>();

  FilterScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NavigationBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Фильтр')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<Map<String, List<Subcategory>>>(
              future: bloc.database.getSubcategories(),
              builder: (_, snap) {
                if (snap.hasData) {
                  final categories = snap.data;

                  return SingleChildScrollView(
                    child: Column(
                      children: categories.keys
                          .map((name) => CategoryItem(
                                categoryName: name,
                                subcategories: categories[name],
                              ))
                          .toList(),
                    ),
                  );
                }
                if (snap.hasError) return Center(child: Text('Ошибка'));
                return Center(child: CircularProgressIndicator());
              },
            ),
            flex: 2,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _key,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 30),
                      child: Material(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Название города',
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 20),
                          ),
                          controller: cityController,
                          validator: (v) {
                            if (v.isEmpty)
                              return 'Название не должно быть пустым';
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    FlatButton(
                      color: Colors.blue,
                      textColor: Colors.white,
                      child: Text('Искать'),
                      onPressed: () {
                        if (_key.currentState.validate()) {
                          bloc.filterMasters(bloc.database
                              .getMastersByCity(cityController.text, 0));
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            flex: 1,
          ),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String categoryName;
  final List<Subcategory> subcategories;

  CategoryItem({
    Key key,
    @required this.categoryName,
    @required this.subcategories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NavigationBloc>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                onTap: () {
                  bloc.filterMasters(bloc.database
                      .getMastersByCategory(subcategories[0].categoryId, 0));
                  Navigator.of(context).pop();
                },
                title: Text(
                  categoryName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ...subcategories
                  .map((s) => SubcategoryWidget(subcategory: s))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class SubcategoryWidget extends StatelessWidget {
  final Subcategory subcategory;

  SubcategoryWidget({Key key, @required this.subcategory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NavigationBloc>(context);

    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: ListTile(
        onTap: () {
          bloc.filterMasters(
              bloc.database.getMastersByCompetence(subcategory.id, 0));
          Navigator.of(context).pop();
        },
        title: Text(subcategory.name),
        trailing: Text('${subcategory.executionTime} мин.'),
        subtitle: Text('${subcategory.price} руб.'),
      ),
    );
  }
}
