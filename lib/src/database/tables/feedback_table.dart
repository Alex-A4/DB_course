import 'package:db_course_mobile/src/database/tables/table_db.dart';

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
}
