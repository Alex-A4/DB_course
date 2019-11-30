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

  /// Создание записей по умолчанию
  Future<void> createDefault(Database db) async {
    /// Первый клиент
    await addFeedback(
        db, 1, 'Очень хороший мастер', DateTime(2019, 2, 5, 16, 2));
    await addFeedback(db, 3, 'Всем рекомендую', DateTime(2019, 5, 9, 12, 36));

    /// Второй клиент
    await addFeedback(
        db,
        5,
        'Очень нравится мастер, хожу не первый раз, всем советую',
        DateTime(2019, 5, 2, 9, 7));
  }

  Future<Feedback> addFeedback(
      Database db, int entryId, String text, DateTime date) async {
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
  /// Начиная с новых
  Future<List<Feedback>> getMasterFeedback(Database db, int masterId,
      EntryTable entryTable, SubcategoryTable subcategoryTable) async {
    final feedbackData = await db.rawQuery('''
    SELECT DISTINCT $tableName.feedback_id, $tableName.entry_id, 
    $tableName.feedback_time, $tableName.feedback_text, sub.name 
    FROM $tableName
      INNER JOIN ${entryTable.tableName} as ent ON
        ent.entry_id = $tableName.entry_id AND ent.master_id = $masterId
      INNER JOIN ${subcategoryTable.tableName} as sub ON
        sub.subcategory_id = ent.subcategory_id;
    ORDER BY tableName.feedback_time DESC;
    ''');

    return feedbackData
        .map((f) => Feedback.withSubcategory(f))
        .cast<Feedback>()
        .toList();
  }
}
