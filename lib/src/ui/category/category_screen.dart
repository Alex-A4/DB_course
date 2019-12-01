import 'package:db_course_mobile/src/ui/bottom_bar.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  CategoryScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Категории')),
      body: Column(
        children: <Widget>[],
      ),
      bottomNavigationBar: CustomBottomBar(),
    );
  }
}
