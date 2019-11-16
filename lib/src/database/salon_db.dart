import 'package:db_course_mobile/src/database/tables/authrization_table.dart';
import 'package:db_course_mobile/src/database/tables/user_table.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// База данных салона, которая содержит всё необходимую информацию о таблицах,
/// позволяет совершать запросы, вставки и пр.
class SalonDB {
  /// Путь к базе данных на диске
  final String path;

  /// Конструктор
  SalonDB(this.path);

  /// Список таблиц
  final _userTable = UserTable();
  final _authTable = AuthorizationTable();

  Database _database;

  Future<Database> get database async {
    if (_database == null) {
      _database = await getDBInstance();
    }

    return _database;
  }

  /// Получение объекта БД, а также создание её, если не существовало.
  Future<Database> getDBInstance() async {
    final dbPath = join(path, 'salon.db');

    return await openDatabase(dbPath, version: 1,
        onCreate: (db, version) async {
      await db.execute(_userTable.createTable);

      await db.execute(_authTable.createTable);
    });
  }

  /// Закрытие БД
  void close() => _database?.close();
}
