import 'package:db_course_mobile/src/bloc/navigation_bloc/navigation.dart';
import 'package:db_course_mobile/src/models/subcategory.dart';
import 'package:db_course_mobile/src/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class MasterCategoryItem extends StatelessWidget {
  final double priceCoef;
  final User master;
  final String categoryName;
  final List<Subcategory> subcategories;

  MasterCategoryItem({
    Key key,
    @required this.categoryName,
    @required this.subcategories,
    @required this.priceCoef,
    @required this.master,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 5, bottom: 5),
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
              ...subcategories
                  .map((s) => SubcategoryWidget(
                        master: master,
                        subcategory: s,
                        priceCoef: priceCoef,
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class SubcategoryWidget extends StatelessWidget {
  final double priceCoef;
  final User master;
  final Subcategory subcategory;

  SubcategoryWidget({
    Key key,
    @required this.subcategory,
    @required this.priceCoef,
    @required this.master,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(RecordRoute(
            master: master,
            priceCoef: priceCoef,
            subcategory: subcategory,
          ));
        },
        title: Text(subcategory.name),
        trailing: Text('${subcategory.executionTime} мин.'),
        subtitle: Text('${(subcategory.price * priceCoef).toInt()} руб.'),
      ),
    );
  }
}

class RecordRoute extends PopupRoute {
  final double priceCoef;
  final User master;
  final Subcategory subcategory;

  RecordRoute({this.master, this.priceCoef, this.subcategory});

  @override
  Color get barrierColor => Colors.black45;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => 'Запись к мастеру';

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Center(
      child: SizedBox(
        height: 250,
        width: 300,
        child: EntryCreator(
          master: master,
          priceCoef: priceCoef,
          subcategory: subcategory,
        ),
      ),
    );
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 200);
}

class EntryCreator extends StatefulWidget {
  final double priceCoef;
  final User master;
  final Subcategory subcategory;

  EntryCreator({Key key, this.priceCoef, this.master, this.subcategory})
      : super(key: key);

  @override
  _EntryCreatorState createState() => _EntryCreatorState();
}

class _EntryCreatorState extends State<EntryCreator> {
  DateTime entryTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NavigationBloc>(context);
    final user = bloc.user;

    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(widget.subcategory.name),
            trailing: Text('${widget.subcategory.executionTime} мин.'),
            subtitle: Text(
                '${(widget.subcategory.price * widget.priceCoef).toInt()} руб.'),
          ),
          SizedBox(
            height: 100,
            child: CupertinoDatePicker(
              backgroundColor: Colors.transparent,
              use24hFormat: true,
              mode: CupertinoDatePickerMode.dateAndTime,
              onDateTimeChanged: (DateTime value) =>
                  setState(() => entryTime = value),
              initialDateTime: entryTime,
            ),
          ),
          FlatButton(
            textColor: Colors.white,
            color: Colors.blue,
            child: Text('Записаться'),
            onPressed: () {
              bloc.database
                  .createEntry(
                    user.token,
                    user.id,
                    widget.master.id,
                    widget.subcategory.id,
                    entryTime,
                  )
                  .then((_) => Fluttertoast.showToast(
                      msg: 'Вы успешно записаны к ${widget.master.name}'));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
