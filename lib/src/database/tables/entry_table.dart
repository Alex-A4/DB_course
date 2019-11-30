import 'package:db_course_mobile/src/database/tables/feedback_table.dart';
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

  /// Создаём записи по умолчанию
  Future<void> createDefault(Database db) async {
    /// Первый клиент
    await createEntry(db, 5, 2, 2, DateTime(2019, 2, 5, 14, 20));
    await createEntry(db, 5, 2, 1, DateTime(2019, 3, 20, 15, 0));
    await createEntry(db, 5, 4, 11, DateTime(2019, 5, 9, 11, 30));

    /// Второй клиент
    await createEntry(db, 6, 3, 8, DateTime(2019, 5, 2, 16, 0));
    await createEntry(db, 6, 4, 11, DateTime(2019, 5, 1, 12, 30));
    await createEntry(db, 6, 2, 3, DateTime(2019, 8, 9, 9, 15));
    await createEntry(db, 6, 4, 12, DateTime(2019, 9, 5, 20, 0));
    await createEntry(db, 6, 2, 1, DateTime(2019, 9, 19, 18, 20));
  }

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

  /// Получаем запись по id, туда включен отзыв, если он есть
  Future<Entry> getEntryById(
      Database db, int entryId, FeedbackTable feedback) async {
    final entryData = await db.rawQuery('''
    SELECT $tableName.entry_id, $tableColumns, f.feedback_id, f.feedback_time, 
        f.feedback_text
    FROM $tableName
      LEFT JOIN ${feedback.tableName} as f ON
        f.entry_id = $entryId;
    ''');

    if (entryData.isEmpty) return null;
    return Entry.withFeedback(entryData.first);
  }

  /// Получаем список записей у мастера
  Future<List<Entry>> getMasterEntries(
      Database db, int masterId, FeedbackTable feedback) async {
    final entriesData = await db.rawQuery('''
    SELECT $tableName.entry_id, $tableColumns, f.feedback_id, f.feedback_time, 
        f.feedback_text
    FROM $tableName 
      LEFT JOIN ${feedback.tableName} as f ON
        f.entry_id = $tableName.entry_id
    WHERE master_id = $masterId
    ORDER BY $tableName.entry_date DCS;
    ''');

    return entriesData.map((e) => Entry.withFeedback(e)).cast<Entry>().toList();
  }

  /// Получаем список записей клиента
  Future<List<Entry>> getClientEntries(
      Database db, int clientId, FeedbackTable feedback) async {
    final entriesData = await db.rawQuery('''
    SELECT $tableName.entry_id, $tableColumns, f.feedback_id, f.feedback_time, 
        f.feedback_text
    FROM $tableName 
      LEFT JOIN ${feedback.tableName} as f ON
        f.entry_id = $tableName.entry_id
    WHERE client_id = $clientId;
    ORDER BY $tableName.entry_date DCS;
    ''');

    return entriesData.map((e) => Entry.withFeedback(e)).cast<Entry>().toList();
  }
}
