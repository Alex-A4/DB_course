import 'package:db_course_mobile/src/database/tables/table_db.dart';

/// Таблица категорий(разделов), является верхним уровнем в иерархии категорий,
/// описывает общие разделы.
class CategoryTable extends TableDb {
  /// Создаёт таблицу с названием раздела и id
  @override
  String get createTable => '''
  CREATE TABLE IF NOT EXISTS $tableName (
    category_id    INTEGER PRIMARY KEY NOT NULL,
    name           TEXT NOT NULL
  )''';

  @override
  String get tableName => 'Category';
}
