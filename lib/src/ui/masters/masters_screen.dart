import 'package:db_course_mobile/src/ui/bottom_bar.dart';
import 'package:flutter/material.dart';

class MastersScreen extends StatelessWidget {
  MastersScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Мастера')),
      body: Column(
        children: <Widget>[],
      ),
      bottomNavigationBar: CustomBottomBar(),
    );
  }
}
