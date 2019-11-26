import 'package:db_course_mobile/src/database/tables/table_db.dart';
import 'package:db_course_mobile/src/models/entry.dart';
import 'package:sqflite/sqlite_api.dart';

/// Таблица записей клиентов к мастерам
class EntryTable extends TableDb {
  /// Создаёт таблицу, которая устанавливает связь между клиентом и мастером,
  /// а также указывается идентификатор процедуры и дата приёма.
  @override
  String get createTable => '''
  CREATE TABLE IF NOT EXISTS $tableName (
    entry_id          INTEGER PRIMARY KEY NOT NULL,
    master_id         INTEGER NOT NULL,
    client_id         INTEGER NOT NULL,
    subcategory_id    INTEGER NOT NULL,
    entry_date        INTEGER NOT NULL,
    
    FOREIGN KEY (subcategory_id)
        REFERENCES Subcategory(subcategory_id)
          ON UPDATE NO ACTION
          ON DELETE NO ACTION
    FOREIGN KEY (master_id)
        REFERENCES User(user_id)
          ON UPDATE NO ACTION
          ON DELETE NO ACTION
    FOREIGN KEY (client_id)
        REFERENCES User(user_id)
          ON UPDATE NO ACTION
          ON DELETE NO ACTION
  )''';

  @override
  String get tableName => 'Entry';

  @override
  String get tableColumns => 'master_id, client_id, subcategory_id, entry_date';

  /// Запись клиента к мастеру на выполнение работы на время [date]
  Future<Entry> createEntry(Database db, int clientId, int masterId,
      int subcategoryId, DateTime date) async {
    final id = await db.rawInsert('''
    INSERT INTO $tableName ($tableColumns)
    VALUES($masterId, $clientId, $subcategoryId, ${date.millisecondsSinceEpoch});
    ''');

    final entryData = await db.rawQuery('''
    SELECT entry_id, $tableColumns FROM $tableName WHERE entry_id = $id;
    ''');

    return Entry.fromData(entryData.first);
  }

  /// Получаем список записей у мастера
  Future<List<Entry>> getMasterEntries(Database db, int masterId) async {
    final entriesData = await db.rawQuery('''
    SELECT * FROM $tableName WHERE master_id = $masterId;
    ''');

    return entriesData.map((e) => Entry.fromData(e)).cast<Entry>().toList();
  }

  /// Получаем список записей клиента
  Future<List<Entry>> getClientEntries(Database db, int clientId) async {
    final entriesData = await db.rawQuery('''
    SELECT * FROM $tableName WHERE client_id = $clientId;
    ''');

    return entriesData.map((e) => Entry.fromData(e)).cast<Entry>().toList();
  }
}
