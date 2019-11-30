import 'package:db_course_mobile/src/database/tables/table_db.dart';
import 'package:db_course_mobile/src/models/category.dart';
import 'package:sqflite/sqflite.dart';

/// Таблица категорий(разделов), является верхним уровнем в иерархии категорий,
/// описывает общие разделы.
class CategoryTable extends TableDb {
  /// Создаёт таблицу с названием раздела и id
  @override
  String get createTable => '''
  CREATE TABLE IF NOT EXISTS $tableName (
    category_id      INTEGER PRIMARY KEY NOT NULL,
    category_name    TEXT NOT NULL
  )''';

  @override
  String get tableName => 'Category';

  @override
  String get tableColumns => 'category_name';

  /// Создание записей по умолчанию
  Future<void> createDefault(Database db) async {
    await db.rawInsert('''
    INSERT INTO $tableName (category_name)
    VALUES 
           ("Маникюр"),
           ("Брови"),
           ("Массаж");
    ''');
  }

  Future<Category> addCategory(Database db, String name) async {
    final id = await db.rawInsert('''
    INSERT INTO $tableName (category_name) 
    VALUES ("$name");
    ''');
    final categoryData = await db.rawQuery('''
    SELECT * FROM $tableName WHERE category_id = $id;
    ''');

    return Category.fromData(categoryData.first);
  }
}
