/// Базовая версия таблицы, которая содержит общую информацию и базовые
/// настройки, такие как запрос создания таблицы.
abstract class TableDb {
  String get tableName;
  String get createTable;
}
