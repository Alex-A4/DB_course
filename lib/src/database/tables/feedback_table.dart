import 'package:db_course_mobile/src/database/tables/entry_table.dart';
import 'package:db_course_mobile/src/database/tables/subcategory_table.dart';
import 'package:db_course_mobile/src/database/tables/table_db.dart';
import 'package:db_course_mobile/src/models/feedback.dart';
import 'package:sqflite/sqlite_api.dart';

/// Таблица отзывов, которые пользователи могут оставить под записью
class FeedbackTable extends TableDb {
  /// Создаёт таблицу, которая устанавливает связь 1-1 с записями.
  /// Содержит дату и время отзыва.
  @override
  String get createTable => '''
  CREATE TABLE IF NOT EXISTS $tableName (
    feedback_id      INTEGER PRIMARY KEY NOT NULL,
    entry_id         INTEGER NOT NULL,
    feedback_time    INTEGER NOT NULL,
    feedback_text    TEXT NOT NULL,
    
    FOREIGN KEY (entry_id)
        REFERENCES Entry(entry_id)
          ON UPDATE NO ACTION
          ON DELETE NO ACTION
  )''';

  @override
  String get tableName => 'Feedback';

  @override
  String get tableColumns => 'entry_id, feedback_time, feedback_text';

  Future<Feedback> addFeedback(Database db, int clientId, int entryId,
      String text, DateTime date) async {
    final id = await db.rawInsert('''
    INSERT INTO $tableName ($tableColumns)
    VALUES ($entryId, ${date.millisecondsSinceEpoch}, "$text");
    ''');
    final feedbackData = await db.rawQuery('''
    SELECT * FROM $tableName WHERE feedback_id = $id;
    ''');

    return Feedback.fromData(feedbackData.first);
  }

  /// Получаем отзыв по номеру записи
  Future<Feedback> getFeedback(Database db, entryId) async {
    final data = await db.rawQuery('''
    SELECT * FROM $tableName WHERE entry_id = $entryId;
    ''');

    if (data.isEmpty) return null;
    return Feedback.fromData(data.first);
  }

  Future<void> updateFeedback(Database db, int feedbackId) async {}

  /// Возвращает список отзывов о мастере
  Future<List<Feedback>> getMasterFeedback(Database db, int masterId,
      EntryTable entryTable, SubcategoryTable subcategoryTable) async {
    final feedbackData = await db.rawQuery('''
    SELECT DISTINCT $tableName.feedback_id, $tableColumns, sub.name 
    FROM $tableName
      INNER JOIN ${entryTable.tableName} as ent ON
        ent.entry_id = $tableName.entry_id AND ent.master_id = $masterId
      INNER JOIN ${subcategoryTable.tableName} as sub ON
        sub.subcategory_id = ent.subcategory_id;
    ''');

    return feedbackData
        .map((f) => Feedback.withSubcategory(f))
        .cast<Feedback>()
        .toList();
  }
}
