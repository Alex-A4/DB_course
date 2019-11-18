import 'package:db_course_mobile/src/database/tables/table_db.dart';

/// Таблица авторизации, содержит id пользователя и токен авторизации
class AuthorizationTable extends TableDb {
  /// Создаёт таблицу с информацией об авторизации пользователя.
  /// Если пользователь авторизован, то в поле token записывается некоторое значение,
  /// а user_id является идентификатором пользователя.
  /// Если пользователь не авторизован, то доступ должен быть закрыт.
  @override
  String get createTable => '''
  CREATE TABLE IF NOT EXISTS $tableName (
    user_id      INTEGER NOT NULL,
    token        TEXT,
    FOREIGN KEY (user_id)
        REFERENCES User(user_id)
          ON UPDATE RESTRICT
          ON DELETE CASCADE
  )''';

  @override
  String get tableName => 'Auth';

  @override
  String get tableColumns => 'user_id, token';
}
