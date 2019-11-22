import 'package:db_course_mobile/src/database/tables/subcategory_table.dart';
import 'package:db_course_mobile/src/database/tables/table_db.dart';
import 'package:db_course_mobile/src/database/tables/user_table.dart';
import 'package:sqflite/sqflite.dart';

/// Таблица компетенции мастеров в каких-либо услугах.
class MasterCompetenceTable extends TableDb {
  /// Создаёт таблицу-связку между мастерами и услугами, которые они
  /// предоставляют для клиентов.
  @override
  String get createTable => '''
  CREATE TABLE IF NOT EXISTS $tableName (
    subcategory_id    INTEGER NOT NULL,
    user_id           INTEGER NOT NULL,
    PRIMARY KEY(user_id, subcategory_id)
  )''';

  @override
  String get tableName => 'MasterCompetence';

  @override
  String get tableColumns => 'subcategory_id, user_id';

  Future<void> addCompetenceToMaster(
      Database db,
      String phone,
      String subcategoryName,
      SubcategoryTable subcategory,
      UserTable user) async {
    await db.rawInsert('''
    INSERT INTO $tableName (subcategory_id, user_id)
    VALUES(
    (SELECT subcategory_id FROM ${subcategory.tableName} WHERE 
    name = "$subcategoryName" COUNT 1),
    (SELECT user_id FROM ${user.tableName} WHERE phone_number = "$phone" COUNT 1)
    );
    ''');
  }
}
