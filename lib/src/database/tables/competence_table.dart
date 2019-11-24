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
      ON CONFLICT IGNORE;
  )''';

  @override
  String get tableName => 'MasterCompetence';

  @override
  String get tableColumns => 'subcategory_id, user_id';

  Future<void> addCompetenceToMaster(Database db, int userId, int subcategoryId,
      UserTable user, SubcategoryTable subcategory) async {
    final master = await db.rawQuery('''
    SELECT role FROM ${user.tableName} WHERE user_id = $userId LIMIT 1;
    ''');
    if (master.first['role'] == 1) throw Exception('Wrong user role');

    await db.rawInsert('''
    INSERT INTO $tableName (subcategory_id, user_id)
    VALUES($subcategoryId, $userId);
    ''');
  }
}
