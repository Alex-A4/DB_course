import 'package:db_course_mobile/src/bloc/navigation_bloc/navigation.dart';
import 'package:db_course_mobile/src/models/entry.dart';
import 'package:db_course_mobile/src/ui/bottom_bar.dart';
import 'package:db_course_mobile/src/ui/profile/entry_widget.dart';
import 'package:db_course_mobile/src/ui/profile/info_pair.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NavigationBloc>(context);
    final user = bloc.user;

    return Scaffold(
      appBar: AppBar(title: Text('Профиль')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: Column(
          children: <Widget>[
            InfoPair(title: 'Имя', content: user.name),
            InfoPair(title: 'Фамилия', content: user.lastName),
            InfoPair(title: 'Роль', content: user.roleString),
            InfoPair(title: 'Телефон', content: user.phone),
            SizedBox(height: 20),
            if (!user.isAdmin)
              Text(
                'Записи',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            EntriesWidget(
              future: user.isAdmin
                  ? null
                  : user.isMaster
                      ? bloc.database.getMasterEntries(user.token, user.id)
                      : bloc.database.getClientEntries(user.token, user.id),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(),
    );
  }
}

class EntriesWidget extends StatelessWidget {
  final Future<List<Entry>> future;

  EntriesWidget({Key key, @required this.future}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (future == null) return Container();
    return FutureBuilder<List<Entry>>(
      future: future,
      builder: (_, snap) {
        if (snap.hasData) {
          final entries = snap.data;
          print(entries);
          return SingleChildScrollView(
            child: Column(
              children: entries.map((e) => EntryWidget(entry: e)).toList(),
            ),
          );
        }
        if (snap.hasError) {
          print(snap.error);
          return Center(child: Text('Ошибка'));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
