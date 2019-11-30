import 'package:db_course_mobile/src/database/tables/category_table.dart';
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
      ON CONFLICT IGNORE
  )''';

  @override
  String get tableName => 'MasterCompetence';

  @override
  String get tableColumns => 'subcategory_id, user_id';

  /// Создаём записи по умолчанию
  Future<void> createDefault(
      Database db, UserTable user, SubcategoryTable subcategory) async {
    /// Первый мастер
    await addCompetenceToMaster(db, 2, 1, user, subcategory);
    await addCompetenceToMaster(db, 2, 2, user, subcategory);
    await addCompetenceToMaster(db, 2, 3, user, subcategory);
    await addCompetenceToMaster(db, 2, 4, user, subcategory);
    await addCompetenceToMaster(db, 2, 10, user, subcategory);

    /// Второй мастер
    await addCompetenceToMaster(db, 3, 1, user, subcategory);
    await addCompetenceToMaster(db, 3, 2, user, subcategory);
    await addCompetenceToMaster(db, 3, 3, user, subcategory);
    await addCompetenceToMaster(db, 3, 8, user, subcategory);
    await addCompetenceToMaster(db, 3, 9, user, subcategory);

    /// Третий мастер
    await addCompetenceToMaster(db, 4, 10, user, subcategory);
    await addCompetenceToMaster(db, 4, 11, user, subcategory);
    await addCompetenceToMaster(db, 4, 12, user, subcategory);
    await addCompetenceToMaster(db, 4, 7, user, subcategory);
  }

  /// Добавляем мастеру компетенцию
  Future<void> addCompetenceToMaster(Database db, int userId, int subcategoryId,
      UserTable user, SubcategoryTable subcategory) async {
    await db.rawInsert('''
    INSERT INTO $tableName (subcategory_id, user_id)
    VALUES($subcategoryId, $userId);
    ''');
  }

  /// Получаем список компетенций мастера
  Future<List<Subcategory>> getMasterCompetence(
      Database db,
      int masterId,
      UserTable userTable,
      SubcategoryTable subcategory,
      CategoryTable category) async {
    final list = await db.rawQuery('''
    SELECT sub.subcategory_id, sub.category_id, sub.name, sub.base_price, 
      sub.execution_time, cat.category_name
    FROM ${subcategory.tableName} as sub
      INNER JOIN $tableName as c ON  
        c.user_id = $masterId AND sub.subcategory_id = c.subcategory_id
      INNER JOIN ${category.tableName} as cat ON
        cat.category_id = sub.category_id
    ORDER BY sub.category_id ASC, sub.subcategory_id ASC;
    ''');

    return list
        .map((e) => Subcategory.fromData(e))
        .cast<Subcategory>()
        .toList();
  }
}
