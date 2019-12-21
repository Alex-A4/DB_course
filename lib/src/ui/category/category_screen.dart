import 'package:db_course_mobile/src/bloc/navigation_bloc/navigation.dart';
import 'package:db_course_mobile/src/database/tables/user_table.dart';
import 'package:db_course_mobile/src/models/subcategory.dart';
import 'package:db_course_mobile/src/ui/bottom_bar.dart';
import 'package:db_course_mobile/src/ui/category/add_category.dart';
import 'package:db_course_mobile/src/ui/category/add_subcategory.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  CategoryScreen({Key key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NavigationBloc>(context);
    final user = bloc.user;

    return Scaffold(
      appBar: AppBar(title: Text('Категории')),
      body: FutureBuilder<Map<String, List<Subcategory>>>(
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: user.isAdmin
          ? Builder(
              builder: (ctx) => FloatingActionButton(
                onPressed: () {
                  Scaffold.of(ctx).showBottomSheet(
                    (_) => AddCategoryScreen(onSuccess: () => setState(() {})),
                  );
                },
                child: Icon(Icons.add),
              ),
            )
          : null,
      bottomNavigationBar: CustomBottomBar(),
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
    final user = bloc.user;

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
              Text(
                categoryName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (subcategories.length == 1 && subcategories[0].id != null ||
                  subcategories.length != 1)
                ...subcategories
                    .map((s) => SubcategoryWidget(subcategory: s))
                    .toList(),
              if (user.isAdmin)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: FlatButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => AddSubcategoryScreen(
                                categoryId: subcategories[0].categoryId,
                                categoryName: categoryName,
                              )),
                    ),
                    child: Text('Добавить в категорию $categoryName'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SubcategoryWidget extends StatefulWidget {
  final Subcategory subcategory;

  SubcategoryWidget({Key key, @required this.subcategory}) : super(key: key);

  @override
  _SubcategoryWidgetState createState() => _SubcategoryWidgetState();
}

class _SubcategoryWidgetState extends State<SubcategoryWidget> {
  bool isSupportByMaster;

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NavigationBloc>(context);
    final user = bloc.user;
    Widget leading;
    if (user.role == Roles.Master) {
      if (bloc.masterCompetence[widget.subcategory.categoryName]
              ?.contains(widget.subcategory) ==
          true)
        isSupportByMaster = true;
      else
        isSupportByMaster = false;
      if (isSupportByMaster)
        leading = Icon(Icons.check, color: Colors.green[300]);
      else
        leading = Icon(Icons.close, color: Colors.red[300]);
    } else
      leading = Container();

    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: ListTile(
        onTap: () {
          if (user.role == Roles.Master) {
            if (!isSupportByMaster)
              bloc.database
                  .addMasterCompetence(
                      user.token, user.id, widget.subcategory.id)
                  .then((_) {
                if (bloc.masterCompetence[widget.subcategory.categoryName] ==
                    null)
                  bloc.masterCompetence[widget.subcategory.categoryName] = [
                    widget.subcategory
                  ];
                else
                  bloc.masterCompetence[widget.subcategory.categoryName]
                      .add(widget.subcategory);
                setState(() => isSupportByMaster = true);
                Fluttertoast.showToast(msg: 'Компетенция добавлена');
              });
            else
              Fluttertoast.showToast(msg: 'Компетенция уже существует');
          } else {
            bloc.dispatch(MastersEvent());
            bloc.filterMasters(
                bloc.database.getMastersByCompetence(widget.subcategory.id, 0));
          }
        },
        leading: leading,
        title: Text(widget.subcategory.name ?? ''),
        trailing: Text('${widget.subcategory.executionTime ?? ''} мин.'),
        subtitle: Text('${widget.subcategory.price ?? ''} руб.'),
      ),
    );
  }
}
