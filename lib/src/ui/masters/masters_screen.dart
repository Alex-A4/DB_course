import 'package:db_course_mobile/src/bloc/navigation_bloc/navigation.dart';
import 'package:db_course_mobile/src/models/user.dart';
import 'package:db_course_mobile/src/ui/bottom_bar.dart';
import 'package:db_course_mobile/src/ui/masters/filter_list.dart';
import 'package:db_course_mobile/src/ui/masters/master_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MastersScreen extends StatelessWidget {
  MastersScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NavigationBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Мастера'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => bloc.filterMasters(bloc.database.getMasters(0)),
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => FilterScreen()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<User>>(
        stream: bloc.masters,
        builder: (_, snap) {
          if (snap.hasData) return MastersList(masters: snap.data);

          if (snap.hasError) return Center(child: Text('Ошибка'));

          return Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: CustomBottomBar(),
    );
  }
}

/// Список мастеров
class MastersList extends StatelessWidget {
  final List<User> masters;

  MastersList({Key key, @required this.masters}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (masters.isEmpty) return Center(child: Text('Мастеров нет'));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemBuilder: (_, index) => MasterItem(master: masters[index]),
      itemCount: masters.length,
    );
  }
}

class MasterItem extends StatelessWidget {
  final User master;

  MasterItem({Key key, @required this.master}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MasterWidget(master: master)),
      ),
      title: Text('${master.name} ${master.lastName}'),
      subtitle: Text('Город: ${master.city}'),
      trailing: Text('Коэф: ${master.priceCoef}'),
      isThreeLine: true,
    );
  }
}
