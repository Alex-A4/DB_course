import 'package:db_course_mobile/src/bloc/navigation_bloc/navigation.dart';
import 'package:db_course_mobile/src/ui/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NavigationBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Профиль')),
      body: Column(
        children: <Widget>[],
      ),
      bottomNavigationBar: CustomBottomBar(),
    );
  }
}

class InfoPair extends StatelessWidget {
  final String title;
  final String content;

  InfoPair({Key key, @required this.title, @required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[],
    );
  }
}
