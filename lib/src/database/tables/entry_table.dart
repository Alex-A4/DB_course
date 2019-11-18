import 'package:db_course_mobile/src/database/tables/table_db.dart';

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
}
