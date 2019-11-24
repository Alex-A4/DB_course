import 'package:db_course_mobile/src/database/tables/category_table.dart';
import 'package:db_course_mobile/src/database/tables/table_db.dart';
import 'package:sqflite/sqlite_api.dart';

/// Таблица подкатегорий, является нижним уровнем в иерархии категорий,
/// описывает конкретные процедуры и их параметры.
class SubcategoryTable extends TableDb {
  /// Создаёт таблицу с названием подкатегории, которая описывает
  /// конкретную процедуру.
  /// subcategory_id - идентификатор процедуры
  /// category_id - идентификатор раздела
  /// name - название процедуры
  /// base_price - базовая цена за процедуру, от которой рассчитывается итоговая
  /// стоимость.
  /// execution_time - время выполнения в минутах
  @override
  String get createTable => '''
  CREATE TABLE IF NOT EXISTS $tableName (
    subcategory_id    INTEGER PRIMARY KEY NOT NULL,
    category_id       INTEGER   NOT NULL,
    name              TEXT NOT NULL,
    base_price        REAL NOT NULL,
    execution_time    INTEGER NOT NULL,
    
    FOREIGN KEY (category_id)
        REFERENCES Category(category_id)
          ON UPDATE RESTRICT
          ON DELETE CASCADE
  )''';

  @override
  String get tableName => 'Subcategory';

  @override
  String get tableColumns => 'category_id, name, base_price, execution_time';

  /// Добавляем подкатегорию в БД
  Future<void> addSubcategory(Database db, String name, String categoryName,
      double price, int time, CategoryTable category) async {
    await db.rawInsert('''
    INSERT INTO $tableName (category_id, name, base_price, execution_time)
    VALUES (
    (SELECT category_id FROM ${category.tableName} WHERE name = "$categoryName" LIMIT 1),
    "$name", $price, $time
    );
    ''');
  }
}
