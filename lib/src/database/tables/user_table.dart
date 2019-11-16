import 'package:db_course_mobile/src/database/tables/table_db.dart';

/// Таблица пользователя, является хранилищем информации о пользователе.
class UserTable extends TableDb {
  /// Создаёт таблицу с информацией о пользователе.
  /// user_id - главный ключ, идентификатор
  /// role - роль пользователя, индекс одного из [Roles], обязательна для всех
  /// phone_number - номер телефона (аналог почты), обязательна для всех
  /// first_name - имя пользователя, обязательна для всех
  /// last_name - фамилия пользователя, обязательна для всех
  /// password_hash - хэш пароля пользователя, обязателен для всех
  /// city - город, обязателен только для мастера
  /// price_coef - коэффициент стоимости, обязателен только для мастеров, нужен
  /// для определения итоговой стоимости, которая вычисляется как базовая * коэффициент.
  ///
  /// Роль администратора позволяет выполнять некоторые сложные запросы, например
  /// редактирование категорий
  @override
  String get createTable => '''
  CREATE TABLE IF NOT EXISTS $tableName (
    user_id        INTEGER PRIMARY KEY NOT NULL,
    role           INTEGER NOT NULL,
    phone_number   VARCHAR(20) NOT NULL,
    first_name     VARCHAR(20) NOT NULL,
    last_name      VARCHAR(20) NOT NULL,
    password_hash  TEXT NOT NULL,
    city           TEXT,
    price_coef     REAL
  )''';

  @override
  String get tableName => 'User';
}

/// Роли, которые распределяются среди пользователей
/// [Roles.Master] - роль мастера, который принимает заказы
/// [Roles.Client] - клиент, который ходит на приёмы
/// [Roles.Admin] - администратор, который можешь редактировать БД
enum Roles { Master, Client, Admin }
