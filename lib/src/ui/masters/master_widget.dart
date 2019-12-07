import 'package:db_course_mobile/src/bloc/navigation_bloc/navigation.dart';
import 'package:db_course_mobile/src/models/feedback.dart' as f;
import 'package:db_course_mobile/src/models/subcategory.dart';
import 'package:db_course_mobile/src/models/user.dart';
import 'package:db_course_mobile/src/ui/auth/login_widget.dart';
import 'package:db_course_mobile/src/ui/masters/master_competence.dart';
import 'package:db_course_mobile/src/ui/profile/info_pair.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Страничка мастера, которая позволяет просматривать информацию о нём
class MasterWidget extends StatelessWidget {
  final User master;

  MasterWidget({Key key, @required this.master}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NavigationBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Страничка мастера')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            customInfoPair(title: 'Имя', content: master.name),
            customInfoPair(title: 'Фамилия', content: master.lastName),
            customInfoPair(title: 'Роль', content: master.roleString),
            customInfoPair(title: 'Телефон', content: master.phone),
            customInfoPair(title: 'Город', content: master.city),
            customInfoPair(
              title: 'Коэффициент цены',
              content: '${master.priceCoef}',
            ),
            SizedBox(height: 20),
            SheetButton(
              title: 'Компетенция',
              child: FutureBuilder<Map<String, List<Subcategory>>>(
                future: bloc.database.getMasterCompetences(master.id),
                builder: (_, snap) {
                  if (snap.hasData)
                    return CompetenceList(
                      competence: snap.data,
                      priceCoef: master.priceCoef,
                    );
                  if (snap.hasError) return Text('Ошибка');

                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
            SheetButton(
              title: 'Отзывы',
              child: FutureBuilder(
                future: bloc.database.getFeedbackAboutMaster(master.id),
                builder: (_, snap) {
                  if (snap.hasData) return FeedbackList(feedback: snap.data);
                  if (snap.hasError) return Text('Ошибка');

                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customInfoPair({String title, String content}) {
    return InfoPair(
      title: TextSpan(text: title, style: headerStyle.copyWith(fontSize: 16)),
      content:
          TextSpan(text: content, style: contentStyle.copyWith(fontSize: 15)),
    );
  }
}

/// Кнопка, которая показывает sheetWidget
class SheetButton extends StatelessWidget {
  final String title;
  final Widget child;

  SheetButton({Key key, @required this.child, @required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: Colors.blue,
      textColor: Colors.white,
      onPressed: () => controller = Scaffold.of(context)
          .showBottomSheet((_) => SheetWidget(child: child)),
      child: Text(title),
    );
  }
}

PersistentBottomSheetController controller;

class SheetWidget extends StatelessWidget {
  final Widget child;

  SheetWidget({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 200, minWidth: double.infinity),
      child: Row(
        children: <Widget>[
          Expanded(child: child),
          IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.arrow_downward),
            onPressed: () => controller?.close(),
          ),
        ],
      ),
    );
  }
}

/// Список компетенций мастера
class CompetenceList extends StatelessWidget {
  final double priceCoef;
  final Map<String, List<Subcategory>> competence;

  CompetenceList({Key key, @required this.competence, @required this.priceCoef})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (competence.isEmpty) return Text('Мастер ничего не умеет');

    // TODO: добавить запись к мастеру
    return SingleChildScrollView(
      child: Column(
        children: competence.keys
            .map((name) => MasterCategoryItem(
                  priceCoef: priceCoef,
                  categoryName: name,
                  subcategories: competence[name],
                ))
            .toList(),
      ),
    );
  }
}

/// Список отзывов о мастере
class FeedbackList extends StatelessWidget {
  final List<f.Feedback> feedback;

  FeedbackList({Key key, @required this.feedback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: feedback
            .map((fe) => ListTile(
                  title: Text(fe.text),
                  subtitle: Text('${fe.subcategoryName ?? ''}'),
                  trailing:
                      Text.rich(TextSpan(children: getDate(fe.feedbackTime))),
                  isThreeLine: true,
                ))
            .toList(),
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
