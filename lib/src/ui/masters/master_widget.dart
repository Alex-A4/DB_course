import 'package:db_course_mobile/src/bloc/navigation_bloc/navigation.dart';
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
            Padding(
              padding: EdgeInsets.only(left: 8, top: 10),
              child: Text('Компетенция:'),
            ),
            Expanded(
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

/// Список компетенций мастера
class CompetenceList extends StatelessWidget {
  final double priceCoef;
  final Map<String, List<Subcategory>> competence;

  CompetenceList({Key key, @required this.competence, @required this.priceCoef})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (competence.isEmpty) return Text('Мастер ничего не умеет');

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
