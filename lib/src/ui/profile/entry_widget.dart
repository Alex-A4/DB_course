import 'package:db_course_mobile/src/bloc/navigation_bloc/navigation.dart';
import 'package:db_course_mobile/src/models/entry.dart';
import 'package:db_course_mobile/src/ui/profile/info_pair.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryWidget extends StatefulWidget {
  final Entry entry;

  EntryWidget({Key key, @required this.entry}) : super(key: key);

  @override
  _EntryWidgetState createState() => _EntryWidgetState();
}

class _EntryWidgetState extends State<EntryWidget> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NavigationBloc>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            children: <Widget>[
              InfoPair(title: 'Дата', content: getDate(widget.entry.date)),
            ],
          ),
        ),
      ),
    );
  }

  String getDate(DateTime date) {
    return 'Когда-то';
  }
}
