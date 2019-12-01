import 'package:db_course_mobile/src/bloc/navigation_bloc/navigation.dart';
import 'package:db_course_mobile/src/models/entry.dart';
import 'package:db_course_mobile/src/ui/auth/login_widget.dart';
import 'package:db_course_mobile/src/ui/profile/feedback_widget.dart';
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
    final user = bloc.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            children: <Widget>[
              InfoPair(
                title: TextSpan(text: 'Дата', style: headerStyle),
                content: TextSpan(children: getDate(widget.entry.date)),
              ),
              InfoPair.text(
                title: user.isMaster ? 'Клиент' : 'Мастер',
                content: widget.entry.clientOrMasterName,
              ),
              InfoPair.text(
                title: 'Телефон',
                content: widget.entry.clientOrMasterPhone,
              ),
              InfoPair.text(
                title: 'Процедура',
                content: widget.entry.subcategoryName,
              ),
              if (widget.entry.feedback != null)
                FeedbackWidget(
                  feedback: widget.entry.feedback,
                  entry: widget.entry,
                ),
              if (widget.entry.feedback == null && user.isClient)
                FeedbackWidget(addFeedback: true, entry: widget.entry),
            ],
          ),
        ),
      ),
    );
  }
}

List<TextSpan> getDate(DateTime date) {
  final cur = DateTime.now();
  final min = date.minute < 10 ? '0${date.minute}' : '${date.minute}';
  final hour = date.hour < 10 ? '0${date.hour}' : '${date.hour}';
  final year = date.year;
  final month = date.month < 10 ? '0${date.month}' : '${date.month}';
  final day = date.day < 10 ? '0${date.day}' : '${date.day}';

  final d = '$day.$month${cur.year != year ? '.$year' : ''}\n';
  final clock = '$hour:$min';

  return [
    TextSpan(text: d, style: headerStyle),
    TextSpan(text: clock, style: contentStyle),
  ];
}
