import 'package:db_course_mobile/src/database/salon_db.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'database/tables/user_table.dart';

class App extends StatelessWidget {
  App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Приложение')),
      body: Center(
        child: FlatButton(
          color: Colors.blue[100],
          onPressed: () => signUp(),
          child: Text('Положить'),
        ),
      ),
    );
  }

  Future<void> signUp() async {
    final dir = await getApplicationDocumentsDirectory();
    print(dir.path);
    final db = SalonDB(dir.path);
    final token = await db.logInUser('890959679876', 'fdsagqwdg');
  }
}
