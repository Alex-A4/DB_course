import 'package:db_course_mobile/src/database/tables/authrization_table.dart';
import 'package:db_course_mobile/src/database/tables/table_db.dart';
import 'package:db_course_mobile/src/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

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

  @override
  String get tableColumns => '''
  role, phone_number, first_name, last_name, password_hash, city, price_coef
  ''';

  /// Регистрация нового пользователя.
  /// Если пользователь уже зарегистрирован, то будет выброшено исклчючение.
  /// Если всё окей, вернёт токен.
  Future<String> signUpUser(
      Database db,
      Roles role,
      String phone,
      String name,
      String lastName,
      String passwordHash,
      String city,
      double priceCoefficient) async {
    final oldUser = await db.rawQuery('''
    SELECT * from $tableName WHERE phone_number = $phone;
    ''');

    if (oldUser.isNotEmpty) throw Exception('User already exists');

    final auth = AuthorizationTable();

    await db.rawInsert('''
    INSERT INTO $tableName ($tableColumns)
    VALUES (${role.index}, "$phone", "$name", "$lastName", "$passwordHash", 
    ${'"$city"' ?? 'NULL'}, ${'"$priceCoefficient"' ?? 'NULL'});
    ''');

    await db.rawInsert('''
    INSERT INTO ${auth.tableName} (${auth.tableColumns})
    VALUES ((SELECT MAX(user_id) from $tableName ), "${Uuid().v4()}");
    ''');

    final token = await db.rawQuery('''
    SELECT token from ${auth.tableName} WHERE 
    user_id = (SELECT MAX(user_id) from ${auth.tableName});
    ''');

    print(token);

    return token.first['token'];
  }

  /// Авторизация пользователя в системе
  /// Если пароль или номер неправильные, будет выброшено исключение.
  /// Если всё окей, то вернёт токен.
  Future<String> logInUser(Database db, String phone, String password) async {
    final oldUser = await db.rawQuery('''
    SELECT * FROM $tableName WHERE phone_number = "$phone";
    ''');

    if (oldUser.isEmpty) throw Exception('User not exists');
    if (oldUser.first['password_hash'] != password)
      throw Exception('Wrong password');

    final token = Uuid().v4();
    final auth = AuthorizationTable();

    await db.rawInsert('''
    UPDATE ${auth.tableName}
    SET token = "$token"
    WHERE user_id == ${oldUser.first['user_id']};
    ''');

    return token;
  }

  /// Верификация пользователя по токену.
  /// Если пользователь не существует, то будет выброшена ошибка
  Future<User> verifyUser(
      Database db, String token, AuthorizationTable auth) async {
    final userData = await db.rawQuery('''
    SELECT * FROM $tableName WHERE 
    id = (SELECT id FROM ${auth.tableName} WHERE token = "$token");
    ''');
    if (userData.isEmpty) throw Exception('Token not exists');
    return User.fromData(userData.first);
  }
}

/// Роли, которые распределяются среди пользователей
/// [Roles.Master] - роль мастера, который принимает заказы
/// [Roles.Client] - клиент, который ходит на приёмы
/// [Roles.Admin] - администратор, который можешь редактировать БД
enum Roles { Master, Client, Admin }
