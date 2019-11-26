import 'package:db_course_mobile/src/database/tables/subcategory_table.dart';
import 'package:db_course_mobile/src/database/tables/table_db.dart';
import 'package:db_course_mobile/src/database/tables/user_table.dart';
import 'package:db_course_mobile/src/models/subcategory.dart';
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

  /// Добавляем мастеру компетенцию
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

  /// Получаем список компетенций мастера
  Future<List<Subcategory>> getMasterCompetence(Database db, int masterId,
      UserTable userTable, SubcategoryTable subcategory) async {
    final list = await db.rawQuery('''
    SELECT * FROM ${subcategory.tableName}
      INNER JOIN $tableName as c ON  
        c.user_id = $masterId AND 
        ${subcategory.tableName}.subcategory_id = c.subcategory_id;
      ORDER BY ${subcategory.tableName}.category_id, 
        ${subcategory.tableName}.subcategory_id;
    ''');

    return list
        .map((e) => Subcategory.fromData(e))
        .cast<Subcategory>()
        .toList();
  }
}
